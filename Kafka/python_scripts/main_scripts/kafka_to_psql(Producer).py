from confluent_kafka import Consumer, KafkaError, TopicPartition, OFFSET_BEGINNING
import psycopg2
import json
from psycopg2.extras import execute_values
from datetime import datetime
import sys

# -----------------------------
# Configuration
# -----------------------------
KAFKA_CONFIG = {
    'bootstrap.servers': 'localhost:29092',
    'group.id': 'admission-consumer-group-v1',  # New group
    'auto.offset.reset': 'earliest',
    'enable.auto.commit': False,
}

TOPIC = "admissions-inbound"

DB_CONFIG = {
    'host': 'localhost',
    'port': '5432',
    'database': 'hospital_project',
    'user': 'postgres',
    'password': 'Hello@123'
}

def get_db_connection():
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        print("✅ Connected to PostgreSQL")
        return conn
    except psycopg2.Error as e:
        print(f"❌ Database connection failed: {e}")
        sys.exit(1)

def parse_timestamp(date_str):
    if not date_str or str(date_str).strip().lower() in ('nan', 'none', '', 'null', 'nat'):
        return None
    
    date_str = str(date_str).strip()
    
    # Handle the problem: timestamps with more than 6 decimal places (nanoseconds)
    # Python's %f only supports up to 6 digits (microseconds)
    if '.' in date_str:
        main_part, fractional_part = date_str.split('.', 1)
        # Keep only the first 6 decimal digits (truncate microseconds, discard nano)
        if len(fractional_part) > 6:
            fractional_part = fractional_part[:6]
            date_str = main_part + '.' + fractional_part
    
    # Try multiple common formats
    formats = [
        "%Y-%m-%d %H:%M:%S.%f",   # 2019-03-31 05:22:39.424531
        "%Y-%m-%d %H:%M:%S",      # without fractional seconds
        "%Y-%m-%d",               # date only
    ]
    
    for fmt in formats:
        try:
            return datetime.strptime(date_str, fmt)
        except ValueError:
            continue
    
    # If nothing works, log warning and return None (or raise if you prefer)
    print(f"⚠️ Could not parse date: {date_str}")
    return None
 

def insert_batch(cursor, events):
    if not events:
        return 0
    
    insert_query = """
        INSERT INTO main (
            "Name", "Age", "GENDER", "Blood Type", "Medical Condition", 
            "Doctor", "Hospital", "Insurance Provider", "Billing Amount", 
            "Room Number", "Admission Type", "Medication", "Test Results", 
            "Date of Admission", "Discharge Date"
        ) VALUES %s;
    """
    
    values = []
    for event in events:
        admission_date = parse_timestamp(event.get("Date of Admission"))
        discharge_date = parse_timestamp(event.get("Discharge Date"))
        
        values.append((
            event.get("Name", 'not Found'),
            event.get("Age"),
            event.get("Gender"),
            event.get("Blood Type"),
            event.get("Medical Condition"),
            event.get("Doctor"),
            event.get("Hospital"),
            event.get("Insurance Provider"),
            event.get("Billing Amount"),
            event.get("Room Number"),
            event.get("Admission Type"),
            event.get("Medication"),
            event.get("Test Results"),
            admission_date,
            discharge_date
        ))
    
    execute_values(cursor, insert_query, values, page_size=len(values))
    return len(values)

def main():
    consumer = Consumer(KAFKA_CONFIG)
    
    # Simple assignment without subscribe - avoids the threading issue
    # Manually assign all 3 partitions
    partitions = [
        TopicPartition(TOPIC, 0, OFFSET_BEGINNING),
        TopicPartition(TOPIC, 1, OFFSET_BEGINNING),
        TopicPartition(TOPIC, 2, OFFSET_BEGINNING),
    ]
    
    consumer.assign(partitions)
    
    # Seek all partitions to beginning
    for tp in partitions:
        consumer.seek(tp)
    
    print(f"🎧 Assigned partitions 0, 1, 2 from beginning")
    
    conn = get_db_connection()
    cursor = conn.cursor()
    
    batch = []
    batch_size = 100
    message_count = 0
    inserted_count = 0
    eof_partitions = set()
    total_partitions = 3
    
    try:
        while True:
            msg = consumer.poll(timeout=3.0)
            
            if msg is None:
                # Check if all partitions reached EOF
                if len(eof_partitions) >= total_partitions and message_count > 0:
                    print("✅ All partitions processed")
                    break
                    
                # Flush any remaining batch
                if batch:
                    try:
                        inserted = insert_batch(cursor, batch)
                        conn.commit()
                        inserted_count += inserted
                        print(f"📦 Flushed batch: {inserted} inserted (total: {message_count})")
                        batch = []
                    except Exception as e:
                        print(f"❌ Batch insert failed: {e}")
                        conn.rollback()
                continue
            
            if msg.error():
                if msg.error().code() == KafkaError._PARTITION_EOF:
                    partition = msg.partition()
                    print(f"📖 EOF on partition {partition}")
                    eof_partitions.add(partition)
                    
                    # Process batch at EOF
                    if batch:
                        try:
                            inserted = insert_batch(cursor, batch)
                            conn.commit()
                            inserted_count += inserted
                            print(f"📦 Batch at EOF: {inserted} inserted")
                            batch = []
                        except Exception as e:
                            print(f"❌ Batch failed: {e}")
                    
                    if len(eof_partitions) >= total_partitions:
                        print("✅ All partitions complete")
                        break
                    continue
                else:
                    print(f"❌ Kafka error: {msg.error()}")
                    continue
            
            try:
                event = json.loads(msg.value().decode('utf-8'))
                batch.append(event)
                message_count += 1
                
                if message_count % 100 == 0:
                    print(f"⏳ Consumed {message_count} messages...")
                
                if len(batch) >= batch_size:
                    try:
                        inserted = insert_batch(cursor, batch)
                        conn.commit()
                        inserted_count += inserted
                        print(f"✅ Inserted: {inserted} (total: {message_count})")
                        batch = []
                    except Exception as e:
                        print(f"❌ Insert failed: {e}")
                        conn.rollback()
                        batch = []
                        
            except json.JSONDecodeError as e:
                print(f"❌ JSON error: {e}")
            except Exception as e:
                print(f"❌ Error: {e}")
    
    except KeyboardInterrupt:
        print("\n🛑 Stopped by user")
    
    finally:
        print("\n🧹 Cleaning up...")
        
        if batch:
            try:
                inserted = insert_batch(cursor, batch)
                conn.commit()
                inserted_count += inserted
                print(f"📦 Final batch: {inserted} inserted")
            except Exception as e:
                print(f"❌ Final batch failed: {e}")
        
        cursor.close()
        conn.close()
        consumer.close()
        
        print(f"\n📊 Summary: Consumed: {message_count}, Inserted: {inserted_count}")

if __name__ == "__main__":
    main()