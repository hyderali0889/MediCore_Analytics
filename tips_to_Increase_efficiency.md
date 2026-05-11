**Here's a practical, step-by-step guide to diagnose and optimize your 300k-row PostgreSQL table.**

Your table appears to be a **patient/medical records** table. With 300k rows it’s still medium-sized, but wide columns + bad query patterns + missing indexes will make it feel slow.

### 1. First: Find the actual slow queries

Run these **right now**:

```sql
-- 1. Top slow / frequent queries (install pg_stat_statements if not present)
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

SELECT 
    query,
    calls,
    total_exec_time,
    mean_exec_time,
    rows,
    shared_blks_hit + shared_blks_read as total_blks
FROM pg_stat_statements 
ORDER BY total_exec_time DESC 
LIMIT 20;

-- 2. Check current slow query log (add these to postgresql.conf if not enabled)
-- log_min_duration_statement = 250   -- log queries > 250ms
-- log_statement = 'mod'              -- or 'all' temporarily
```

Also enable `auto_explain`:

```sql
-- In session or globally
SET auto_explain.log_min_duration = 100;
SET auto_explain.log_analyze = true;
SET auto_explain.log_buffers = true;
```

### 2. Analyze your workload patterns

Common slow patterns on a table like yours:

- `WHERE doctor = ?` or `hospital = ?`
- `WHERE admission_date BETWEEN ? AND ?`
- `WHERE test_result = 'Normal'` or `medical_condition = 'Cancer'`
- Searches by `name` or partial name
- Aggregates: `COUNT(*)` by gender/age/blood_type, average billing, etc.
- Recent admissions (`date_of_admission > now() - interval '30 days'`)
- Joins to other tables (doctors, insurance, etc.)

### 3. Recommended Indexing Strategy

**Start with these indexes** (adjust based on your actual queries):

```sql
-- High priority (most common filters)
CREATE INDEX idx_admission_date ON patient_records (date_of_admission);
CREATE INDEX idx_discharge_date ON patient_records (discharge_date);
CREATE INDEX idx_doctor ON patient_records (doctor);
CREATE INDEX idx_hospital ON patient_records (hospital);
CREATE INDEX idx_medical_condition ON patient_records (medical_condition);

-- Composite indexes (very powerful)
CREATE INDEX idx_admission_doctor ON patient_records (date_of_admission, doctor);
CREATE INDEX idx_hospital_admission ON patient_records (hospital, date_of_admission);
CREATE INDEX idx_condition_gender ON patient_records (medical_condition, gender);

-- For text search / names
CREATE INDEX idx_name_trgm ON patient_records USING gin (name gin_trgm_ops);  -- needs pg_trgm extension

-- Partial indexes (if you query recent data a lot)
CREATE INDEX idx_recent_admissions ON patient_records (date_of_admission) 
WHERE date_of_admission > CURRENT_DATE - INTERVAL '90 days';
```

**After creating indexes**, always run:

```sql
ANALYZE patient_records;
```

### 4. When to use **Materialized Views**

Use them when you have **heavy aggregations or reports** that don’t need to be 100% real-time.

Examples:

```sql
CREATE MATERIALIZED VIEW mv_patient_stats AS
SELECT 
    hospital,
    medical_condition,
    gender,
    COUNT(*) as patient_count,
    AVG(age) as avg_age,
    AVG(billing_amount) as avg_billing,
    MIN(date_of_admission) as first_admission
FROM patient_records
GROUP BY hospital, medical_condition, gender;

-- Refresh strategy
REFRESH MATERIALIZED VIEW CONCURRENTLY mv_patient_stats;  -- best with UNIQUE index on MV
```

Schedule refresh with `pg_cron` or external job (nightly or every few hours).

### 5. Regular Views vs Functions

- **Views** → good for encapsulation and security (row-level security)
- **Materialized Views** → good for performance
- **Functions** → best for complex business logic or reusable report queries

Example function:

```sql
CREATE FUNCTION get_patient_summary(p_hospital text, p_days int)
RETURNS TABLE(...) AS $$
    SELECT ... 
    FROM patient_records 
    WHERE hospital = p_hospital 
      AND date_of_admission >= CURRENT_DATE - p_days;
$$ LANGUAGE sql STABLE;
```

### 6. Advanced Optimizations (after basics)

| Technique               | When to use                              | Benefit                     |
|-------------------------|------------------------------------------|-----------------------------|
| **BRIN index**          | On very large date columns               | Tiny index, fast range scans |
| **Partitioning**        | By `date_of_admission` (yearly/monthly)  | Huge win for old data       |
| **Covering indexes**    | Frequent `SELECT name, age, doctor...`   | Index-only scans            |
| **Expression indexes**  | `UPPER(name)` or `date_trunc('day', ...)`| Fast filtered searches      |
| **Clustering**          | `CLUSTER patient_records USING idx_admission_date` | Physical order optimization |

### 7. Quick Diagnostic Query

Run this to see missing indexes for your top queries:

```sql
SELECT 
    schemaname || '.' || tablename as table,
    indexrelname as index_name,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes
WHERE idx_scan = 0 
ORDER BY idx_tup_read DESC;
```

### Recommended Action Plan (Next 1-2 hours)

1. Run the `pg_stat_statements` query → identify top 5-10 slow queries.
2. For each slow query, run `EXPLAIN (ANALYZE, BUFFERS)` and share the output here if you want specific advice.
3. Create the basic single-column indexes on `date_of_admission`, `doctor`, `hospital`, `medical_condition`.
4. Re-run your slow queries and compare times.

