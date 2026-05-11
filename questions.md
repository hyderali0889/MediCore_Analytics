# Hospital Patient Data Analysis - SQL Queries


## 1. Total Admissions and Unique Patients
```sql
SELECT 
    COUNT(*) AS total_admissions,
    COUNT(DISTINCT patient_id) AS unique_patients
FROM main;
```

## 2. Overall Average Length of Stay (LOS)
```sql
SELECT 
    ROUND(AVG(EXTRACT(DAY FROM ("Date of Discharge" - "Date of Admission"))), 2) AS avg_los_days
FROM main
WHERE "Date of Discharge" IS NOT NULL;
```

## 3. Average Length of Stay by Department
```sql
SELECT 
    department,
    COUNT(*) AS admissions,
    ROUND(AVG(EXTRACT(DAY FROM ("Date of Discharge" - "Date of Admission"))), 2) AS avg_los_days
FROM main
WHERE "Date of Discharge" IS NOT NULL
GROUP BY department
ORDER BY avg_los_days DESC;
```

## 4. Average Length of Stay by Diagnosis
```sql
SELECT 
    diagnosis,
    COUNT(*) AS cases,
    ROUND(AVG(EXTRACT(DAY FROM ("Date of Discharge" - "Date of Admission"))), 2) AS avg_los_days
FROM main
WHERE "Date of Discharge" IS NOT NULL
GROUP BY diagnosis
HAVING COUNT(*) >= 50
ORDER BY avg_los_days DESC;
```

## 5. Top 10 Highest Billing Conditions (by Total Revenue)
```sql
SELECT 
    diagnosis,
    COUNT(*) AS cases,
    ROUND(AVG(billing_amount), 2) AS avg_billing,
    ROUND(SUM(billing_amount), 2) AS total_billing
FROM main
GROUP BY diagnosis
ORDER BY total_billing DESC
LIMIT 10;
```

## 6. Top 10 Most Expensive Individual Admissions
```sql
SELECT 
    patient_id, 
    "Date of Admission", 
    diagnosis, 
    billing_amount
FROM main
ORDER BY billing_amount DESC
LIMIT 10;
```

## 7. Average Billing Amount by Department
```sql
SELECT 
    department,
    COUNT(*) AS admissions,
    ROUND(AVG(billing_amount), 2) AS avg_billing,
    ROUND(SUM(billing_amount), 2) AS total_revenue
FROM main
GROUP BY department
ORDER BY total_revenue DESC;
```

## 8. Patient Distribution by Gender
```sql
SELECT 
    gender,
    COUNT(*) AS count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM main
GROUP BY gender
ORDER BY count DESC;
```

## 9. Patient Distribution by Age Group
```sql
SELECT 
    CASE 
        WHEN age < 18 THEN '0-17 (Child)'
        WHEN age < 40 THEN '18-39 (Young Adult)'
        WHEN age < 60 THEN '40-59 (Adult)'
        WHEN age < 80 THEN '60-79 (Senior)'
        ELSE '80+ (Elderly)'
    END AS age_group,
    COUNT(*) AS patient_count,
    ROUND(AVG(billing_amount), 2) AS avg_billing
FROM main
GROUP BY age_group
ORDER BY patient_count DESC;
```

## 10. Monthly Admission Trends
```sql
SELECT 
    DATE_TRUNC('month', "Date of Admission") AS admission_month,
    COUNT(*) AS admissions
FROM main
GROUP BY admission_month
ORDER BY admission_month;
```

## 11. Top 5 Conditions with Longest Average Stay
```sql
SELECT 
    diagnosis,
    COUNT(*) AS cases,
    ROUND(AVG(EXTRACT(DAY FROM ("Date of Discharge" - "Date of Admission"))), 2) AS avg_los_days
FROM main
WHERE "Date of Discharge" IS NOT NULL
GROUP BY diagnosis
ORDER BY avg_los_days DESC
LIMIT 5;
```

## 12. 30-Day Readmission Rate
```sql
WITH next_admission AS (
    SELECT 
        patient_id,
        "Date of Discharge",
        LEAD("Date of Admission") OVER (PARTITION BY patient_id ORDER BY "Date of Admission") AS next_admit_date
    FROM main
)
SELECT 
    ROUND(100.0 * COUNT(CASE WHEN next_admit_date - "Date of Discharge" <= 30 THEN 1 END) 
          / COUNT(*), 2) AS readmission_rate_percent
FROM next_admission
WHERE next_admit_date IS NOT NULL;
```

## 13. Most Common Diagnoses
```sql
SELECT 
    diagnosis, 
    COUNT(*) AS frequency
FROM main
GROUP BY diagnosis
ORDER BY frequency DESC
LIMIT 10;
```

## 14. Average Billing by Age Group and Gender
```sql
SELECT 
    CASE 
        WHEN age < 18 THEN 'Child'
        WHEN age < 40 THEN 'Young Adult'
        WHEN age < 60 THEN 'Adult'
        ELSE 'Senior'
    END AS age_group,
    gender,
    ROUND(AVG(billing_amount), 2) AS avg_billing,
    COUNT(*) AS patients
FROM main
GROUP BY age_group, gender
ORDER BY avg_billing DESC;
```

## 15. Hospital Performance Summary (Dashboard)
```sql
SELECT 
    COUNT(*) AS total_admissions,
    COUNT(DISTINCT patient_id) AS unique_patients,
    ROUND(AVG(EXTRACT(DAY FROM ("Date of Discharge" - "Date of Admission"))), 2) AS overall_avg_los_days,
    ROUND(AVG(billing_amount), 2) AS overall_avg_billing,
    ROUND(SUM(billing_amount), 2) AS total_revenue
FROM main
WHERE "Date of Discharge" IS NOT NULL;
```
