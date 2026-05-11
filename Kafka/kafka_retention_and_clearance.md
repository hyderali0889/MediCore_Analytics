Good question — this is where Kafka internals start to matter.

---

# 🧠 1. How long does Kafka keep data?

Kafka retention is controlled by **topic configuration**, not producers or consumers.

## 🔍 Check retention for a topic

Run:

```bash
docker exec -it kafka kafka-configs \
  --bootstrap-server kafka:9092 \
  --entity-type topics \
  --entity-name admissions-inbound \
  --describe
```

---

## 📌 You will see something like:

```text
retention.ms=604800000
```

---

# ⏱️ What retention means

## 📦 retention.ms = time-based retention

Example:

| Value        | Meaning  |
| ------------ | -------- |
| 604800000 ms | 7 days   |
| 86400000 ms  | 1 day    |
| 60000 ms     | 1 minute |

👉 After this time Kafka deletes old messages

---

## 📦 retention.bytes = size-based retention

Example:

```text
retention.bytes=1073741824
```

Means:
👉 keep only 1GB of data, then delete old logs

---

# ⚙️ Default behavior (important)

If you didn’t configure anything:

👉 Kafka usually keeps data for:

* 7 days (default in many setups)

---

# ✏️ 2. How to change retention

## 🔥 Example: keep data only 1 hour

```bash
docker exec -it kafka kafka-configs \
  --bootstrap-server kafka:9092 \
  --entity-type topics \
  --entity-name admissions-inbound \
  --alter \
  --add-config retention.ms=3600000
```

---

## 🔥 Example: keep only 1 day

```bash
--add-config retention.ms=86400000
```

---

# 🧹 3. How to clear Kafka topic data

You have 3 options:

---

## ✅ OPTION 1: Delete entire topic (BEST CLEAN RESET)

```bash
docker exec -it kafka kafka-topics \
  --bootstrap-server kafka:9092 \
  --delete \
  --topic admissions-inbound
```

Then recreate it if needed.

---

## ⚠️ Important

Topic deletion must be enabled:

```properties
delete.topic.enable=true
```

---

## ✅ OPTION 2: Reduce retention to almost zero (safe trick)

```bash
retention.ms=1000
```

Kafka will delete data within seconds.

---

## ⚠️ OPTION 3: Purge by offset (advanced)

You can move consumer offset forward, but data remains in Kafka until retention kicks in.

---

# 🧠 Key concept

Kafka is NOT like a database where you “delete rows”

Instead:

👉 Kafka is a **log system**
👉 Data disappears based on:

* time (retention.ms)
* size (retention.bytes)

---

# 🔥 Real-world analogy

Think of Kafka like:

🧾 A CCTV recording system:

* keeps footage for 7 days
* automatically deletes old recordings
* or overwrites when disk is full

---

# 🎯 Summary

## To check retention:

```bash
kafka-configs --describe
```

## To control retention:

* `retention.ms` → time
* `retention.bytes` → size

## To clear data:

* delete topic OR
* reduce retention time


