from confluent_kafka import Producer
import pandas as pd
import json
import time
import sys

conf = {
    'bootstrap.servers': 'localhost:29092',
    'client.id': 'admission-producer',
    'retries': 3,
    'retry.backoff.ms': 1000,
    'max.in.flight.requests.per.connection': 5,
    'queue.buffering.max.messages': 100000,
}

producer = Producer(conf)
TOPIC = "admissions-inbound"
delivered = 0
target = 300000

def delivery_report(err, msg):
    global delivered
    if err:
        print(f"❌ Message failed: {err}")
    else:
        delivered += 1
        if delivered % 100 == 0 or delivered == target:
            print(f"✅ Progress: {delivered}/{target}")

df = pd.read_csv("C:\\Data\\Data_Analysis\\Projects\\hospital_project\\Project_CSVs\\synthetic_healthcare_300k.csv")
df.columns = df.columns.str.strip()
df = df.sample(n=target, replace=True).reset_index(drop=True)

print(f"🚀 Producing {target} messages...")

for i, row in df.iterrows():
    event = {
        "Name": row["Name"],
        "Age": int(row["Age"]),
        "Gender": row["Gender"],
        "Blood Type": row["Blood Type"],
        "Medical Condition": row["Medical Condition"],
        "Doctor": row["Doctor"],
        "Hospital": row["Hospital"],
        "Insurance Provider": row["Insurance Provider"],
        "Billing Amount": float(row["Billing Amount"]),
        "Room Number": int(row["Room Number"]),
        "Admission Type": row["Admission Type"],
        "Medication": row["Medication"],
        "Test Results": row["Test Results"],
        "Date of Admission": row["Date of Admission"],
        "Discharge Date": row["Discharge Date"],
    }

    try:
        producer.produce(
            TOPIC,
            key=str(i),
            value=json.dumps(event),
            callback=delivery_report
        )
    except BufferError:
        # Queue full, wait and retry
        print(f"⚠️ Queue full ({len(producer)} messages), waiting...")
        producer.poll(1)
        producer.produce(
            TOPIC,
            key=str(i),
            value=json.dumps(event),
            callback=delivery_report
        )
    
    # Poll to process delivery reports
    producer.poll(0)
    
    # Slow down if queue gets large - FIXED: use len(producer) not producer.len()
    if len(producer) > 1000:
        print(f"⏳ Slowing down, queue size: {len(producer)}")
        producer.poll(0.1)

print(f"📤 Queue size before final flush: {len(producer)}")
producer.flush()
print(f"✅ Total delivered: {delivered}/{target}")

if delivered != target:
    print(f"⚠️ WARNING: Only {delivered} of {target} messages were delivered!")
    sys.exit(1)