import time
import random
import threading
from concurrent.futures import ThreadPoolExecutor

import psycopg2
from psycopg2.extras import RealDictCursor

# ==========================================================
# PostgreSQL Connection Configuration
# ==========================================================
DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "database": "hospital_project",
    "user": "postgres",
    "password": "Hello@123"
}

# ==========================================================
# Benchmark Configuration
# ==========================================================
NUMBER_OF_THREADS = 10
QUERIES_PER_THREAD = 100

# ==========================================================
# Views To Test
# ==========================================================
# Add your PostgreSQL views here
VIEWS_TO_TEST = [
    "avg_bill_by_age",
    # "view_orders",
    # "view_sales_summary"
]

# ==========================================================
# SQL Queries For Automation
# ==========================================================
AUTOMATION_QUERIES = [
    "SELECT * FROM avg_bill_by_age LIMIT 10;",
    # "SELECT * FROM view_orders LIMIT 10;",
    # "SELECT * FROM view_sales_summary LIMIT 10;"
]

# ==========================================================
# Connect To PostgreSQL
# ==========================================================
def get_connection():
    return psycopg2.connect(
        host=DB_CONFIG["host"],
        port=DB_CONFIG["port"],
        database=DB_CONFIG["database"],
        user=DB_CONFIG["user"],
        password=DB_CONFIG["password"]
    )


# ==========================================================
# Execute Query
# ==========================================================
def execute_query(query):
    try:
        conn = get_connection()
        cursor = conn.cursor(cursor_factory=RealDictCursor)

        start_time = time.time()

        cursor.execute(query)

        try:
            result = cursor.fetchall()
        except Exception:
            result = []

        execution_time = round(time.time() - start_time, 4)

        cursor.close()
        conn.close()

        return {
            "success": True,
            "execution_time": execution_time,
            "rows_returned": len(result)
        }

    except Exception as e:
        return {
            "success": False,
            "error": str(e)
        }


# ==========================================================
# Validate Views
# ==========================================================
def validate_views():
    print("\n========== VALIDATING VIEWS ==========")

    conn = get_connection()
    cursor = conn.cursor()

    for view_name in VIEWS_TO_TEST:
        try:
            cursor.execute(f"SELECT COUNT(*) FROM {view_name};")
            count = cursor.fetchone()[0]

            print(f"[SUCCESS] {view_name} -> Rows: {count}")

        except Exception as e:
            print(f"[FAILED] {view_name} -> {e}")

    cursor.close()
    conn.close()


# ==========================================================
# Automation Test
# ==========================================================
def run_automation_tests():
    print("\n========== RUNNING AUTOMATION TESTS ==========")

    for query in AUTOMATION_QUERIES:
        result = execute_query(query)

        if result["success"]:
            print(
                f"[SUCCESS] Time: {result['execution_time']}s | Rows: {result['rows_returned']}"
            )
        else:
            print(f"[FAILED] {result['error']}")


# ==========================================================
# Benchmark Worker
# ==========================================================
def benchmark_worker(worker_id, results):
    print(f"[THREAD-{worker_id}] Started")

    for _ in range(QUERIES_PER_THREAD):
        query = random.choice(AUTOMATION_QUERIES)

        result = execute_query(query)

        if result["success"]:
            results.append(result["execution_time"])

    print(f"[THREAD-{worker_id}] Completed")


# ==========================================================
# Benchmark Test
# ==========================================================
def run_benchmark_test():
    print("\n========== RUNNING BENCHMARK TEST ==========")

    benchmark_results = []

    start_time = time.time()

    with ThreadPoolExecutor(max_workers=NUMBER_OF_THREADS) as executor:
        futures = []

        for thread_id in range(NUMBER_OF_THREADS):
            futures.append(
                executor.submit(
                    benchmark_worker,
                    thread_id,
                    benchmark_results
                )
            )

        for future in futures:
            future.result()

    total_time = round(time.time() - start_time, 2)

    total_queries = len(benchmark_results)

    if total_queries > 0:
        avg_query_time = round(sum(benchmark_results) / total_queries, 4)
        qps = round(total_queries / total_time, 2)

        print("\n========== BENCHMARK RESULTS ==========")
        print(f"Total Queries Executed : {total_queries}")
        print(f"Total Execution Time   : {total_time}s")
        print(f"Average Query Time     : {avg_query_time}s")
        print(f"Queries Per Second     : {qps}")

    else:
        print("No successful benchmark queries executed.")


# ==========================================================
# Main
# ==========================================================
def main():
    print("\n====================================")
    print(" PostgreSQL Views Automation Tool")
    print("====================================")

    validate_views()

    run_automation_tests()

    run_benchmark_test()


if __name__ == "__main__":
    main()


# ==========================================================
# Requirements
# ==========================================================
# Install psycopg2:
#
# pip install psycopg2-binary
#
# ==========================================================
# Run Command
# ==========================================================
# python postgres_views_benchmark.py
# ==========================================================
