**✅ Best Solution: Use Debezium + Kafka Connect (CDC)**

This is the standard, reliable way to automatically send new/updated/deleted rows from **PostgreSQL** to **Kafka** in real-time.

### Step-by-Step Setup

#### 1. Prepare PostgreSQL for CDC (Logical Replication)

Run these commands on your PostgreSQL database:

```sql
-- 1. Set these parameters in postgresql.conf (then restart Postgres)
wal_level = logical
max_wal_senders = 10
max_replication_slots = 10

-- 2. Create a dedicated replication user
CREATE USER debezium REPLICATION LOGIN PASSWORD 'debezium_password';

-- 3. Grant permissions
GRANT SELECT ON ALL TABLES IN SCHEMA public TO debezium;
ALTER ROLE debezium REPLICATION;

-- 4. Create publication (for specific tables - recommended)
CREATE PUBLICATION dbz_publication FOR TABLE patients, conditions, admissions;  -- add your tables
```

#### 2. Run Kafka + Kafka Connect + Debezium

**Easiest way: Use Docker Compose**

Create a `docker-compose.yml`:

```yaml
services:
  zookeeper:
    image: confluentinc/cp-zookeeper:latest
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181

  kafka:
    image: confluentinc/cp-kafka:latest
    depends_on: [zookeeper]
    environment:
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://kafka:9092
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1

  connect:
    image: confluentinc/cp-kafka-connect:latest
    depends_on: [kafka]
    ports:
      - "8083:8083"
    environment:
      CONNECT_BOOTSTRAP_SERVERS: kafka:9092
      CONNECT_REST_PORT: 8083
      CONNECT_GROUP_ID: compose-connect-group
      CONNECT_CONFIG_STORAGE_TOPIC: connect-configs
      CONNECT_OFFSET_STORAGE_TOPIC: connect-offsets
      CONNECT_STATUS_STORAGE_TOPIC: connect-status
      CONNECT_KEY_CONVERTER: org.apache.kafka.connect.json.JsonConverter
      CONNECT_VALUE_CONVERTER: org.apache.kafka.connect.json.JsonConverter
      CONNECT_PLUGIN_PATH: /usr/share/java
    command: 
      - bash 
      - -c 
      - |
        confluent-hub install --no-prompt debezium/debezium-connector-postgresql:2.7.0
        /etc/confluent/docker/run
```

Then start it:

```bash
docker-compose up -d
```

#### 3. Register the Debezium PostgreSQL Connector

Create a file `postgres-connector.json`:

```json
{
  "name": "postgres-cdc-connector",
  "config": {
    "connector.class": "io.debezium.connector.postgresql.PostgresConnector",
    "database.hostname": "your-postgres-host",
    "database.port": "5432",
    "database.user": "debezium",
    "database.password": "debezium_password",
    "database.dbname": "your_database_name",
    "database.server.name": "hospital_db",
    "table.include.list": "public.patients,public.conditions",
    "publication.autocreate.mode": "filtered",
    "slot.name": "debezium_slot",
    "key.converter": "org.apache.kafka.connect.json.JsonConverter",
    "value.converter": "org.apache.kafka.connect.json.JsonConverter"
  }
}
```

Register it:

```bash
curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" \
http://localhost:8083/connectors \
-d @postgres-connector.json
```

### What Happens Next?

- Every time you `INSERT`, `UPDATE`, or `DELETE` a row in PostgreSQL → Debezium captures it instantly.
- The change is sent to Kafka topics like:
  - `hospital_db.public.patients`
  - `hospital_db.public.conditions`

You can now consume these topics in your downstream systems (Materialize, ClickHouse, Flink, etc.) for your Metabase real-time dashboard.

