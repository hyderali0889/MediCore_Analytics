Great — this is the **most important Kafka skill check**: verifying the full pipeline.

You want:

> Produce messages → Consume messages → confirm flow end-to-end

I’ll show you **3 clean ways**, from simplest to production-style.

---

# ✅ OPTION 1: Quick CLI end-to-end test (BEST START)

## 📤 Step 1 — Producer

Run producer:

```bash id="p1"
docker exec -it kafka kafka-console-producer \
  --topic admissions-inbound \
  --bootstrap-server kafka:9092
```

Type a message:

```json id="p2"
{"name":"Ali","age":30,"condition":"fever"}
```

---

## 📥 Step 2 — Consumer (in another terminal)

```bash id="p3"
docker exec -it kafka kafka-console-consumer \
  --topic admissions-inbound \
  --bootstrap-server kafka:9092 \
  --from-beginning
```

---

## 🎯 Expected output

```json id="p4"
{"name":"Ali","age":30,"condition":"fever"}
```

✔ If you see this → **Kafka is working end-to-end**

---

# ✅ OPTION 2: Real-time streaming test (recommended)

This shows **live flow (like production)**

## Terminal 1 (consumer first)

```bash id="c1"
docker exec -it kafka kafka-console-consumer \
  --topic admissions-inbound \
  --bootstrap-server kafka:9092
```

---

## Terminal 2 (producer script or CLI)

Send messages:

```bash id="c2"
docker exec -it kafka kafka-console-producer \
  --topic admissions-inbound \
  --bootstrap-server kafka:9092
```

Type multiple messages:

```json id="c3"
{"name":"A","age":20}
{"name":"B","age":25}
{"name":"C","age":40}
```

---

## 🎯 You should see consumer output instantly

👉 This proves:

* Kafka broker working
* Topic working
* Producer → Consumer flow working

---

# ✅ OPTION 3: Python end-to-end test (BEST for your project)

## 📤 Producer (Python)

Run your CSV producer script.

---

## 📥 Consumer (Python logger)

Create `consumer.py`:

```python id="py1"
from confluent_kafka import Consumer

conf = {
    'bootstrap.servers': 'localhost:29092',
    'group.id': 'test-group',
    'auto.offset.reset': 'earliest'
}

consumer = Consumer(conf)
consumer.subscribe(['admissions-inbound'])

print("📥 Listening for messages...")

while True:
    msg = consumer.poll(1.0)

    if msg is None:
        continue

    if msg.error():
        print("Error:", msg.error())
        continue

    print(f"📦 Received: {msg.value().decode('utf-8')}")
```

---

## ▶️ Run it:

```bash id="py2"
python consumer.py
```

---

## 🎯 Output:

```text id="py3"
📦 Received: {"name":"Ali","age":30,...}
📦 Received: {"name":"Sara","age":25,...}
```

---

# 🔥 OPTION 4: Verify with Kafka CLI (debug mode)

Check topic metadata:

```bash id="d1"
docker exec -it kafka kafka-topics \
  --bootstrap-server kafka:9092 \
  --describe \
  --topic admissions-inbound
```

---

# 🧠 What “end-to-end test” really means

You are verifying:

```text id="flow"
Producer → Kafka Broker → Topic Storage → Consumer
```

NOT:

* just sending messages ❌
* just creating topic ❌

BUT:
👉 full data flow ✔

---

# 🚨 Common mistakes (you might hit)

## ❌ Nothing shows in consumer

✔ Fix:

```bash
--from-beginning
```

---

## ❌ Using wrong port

Inside Docker:

```bash
kafka:9092
```

Outside:

```bash
localhost:29092
```

---

## ❌ No output delay confusion

Kafka is instant — if no output:

* wrong topic
* wrong broker
* wrong network

---

# 🚀 Best practice (what companies do)

They always test with:

✔ console producer
✔ console consumer
✔ then Python producer
✔ then full pipeline (Kafka Connect, DB, etc.)

---

# 🎯 Final takeaway

To test Kafka end-to-end:

👉 Run consumer
👉 Send messages
👉 Verify output appears in real time
