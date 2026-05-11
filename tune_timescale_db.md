tuning PostgreSQL settings like work_mem and shared_buffers is highly recommended for TimescaleDB, especially for your hospital project (which likely involves time-series data, aggregations, length-of-stay calculations, GROUP BY on dates/departments, etc.).
Why it's important for TimescaleDB

Default PostgreSQL values (shared_buffers = 128MB, work_mem = 4MB) are very conservative and often cause slow queries or temp file spills on disk when working with time-series data.
TimescaleDB adds its own workload patterns:
Chunk-based storage
Compression/decompression
time_bucket() aggregations
Large scans or joins on historical data

Poor tuning leads to:
Slow SELECT queries (especially with EXTRACT, time_bucket, or window functions)
Slow compression jobs
High disk I/O (temp files)


Quick Recommendation for Your Docker Setup
Since you're running TimescaleDB in Docker, the easiest and safest way is to use the official timescaledb-tune tool.
Option 1: Use timescaledb-tune (Recommended)
Add this to your docker-compose.yml under the timescaledb service (temporary, for tuning):
```YAML
command: >
      - postgres 
      - -c 
      - shared_preload_libraries=timescaledb
      - -c 
      - timescaledb.telemetry_level=off
```
Then run these commands:
```Bash# 1. Enter the container
docker exec -it timescaledb bash
```
# 2. Run the tuner (answer the questions)
```
timescaledb-tune
```

# 3. It will show recommended values. Apply them by editing postgresql.conf or restarting with new params.
After tuning, restart the container:
```Bash
docker compose restart timescaledb
```