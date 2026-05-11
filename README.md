# hospital_project

# 🏥 Real-Time Healthcare Analytics Platform

A scalable, real-time data analytics platform designed to process, analyze, and visualize healthcare admission data using modern data engineering tools.

---

## 📌 Project Overview

This project builds a **Real-Time Healthcare Analytics Platform** that ingests streaming hospital data, stores it efficiently, and provides actionable insights through dashboards.

### 🎯 Objectives
- Enable real-time data ingestion using Kafka
- Store and optimize healthcare data in PostgreSQL
- Build analytical queries for healthcare insights
- Visualize KPIs using Grafana dashboards
- Ensure performance, scalability, and reliability

---

## 🏗️ Architecture

```
CSV Dataset → Kafka → PostgreSQL → Grafana 
```

### Components:
- **Apache Kafka** – Real-time data streaming
- **PostgreSQL** – Data storage and analytics
- **Grafana** – Visualization and dashboards
- **Docker** – Containerized deployment

---

## 📂 Dataset

- File: `synthetic_healthcare_300k.csv`
- Size: ~300,000 records
- Contains:
  - Patient demographics
  - Admission details
  - Medical conditions
  - Billing information

---

## ⚙️ Tech Stack

| Layer            | Technology        |
|------------------|------------------|
| Data Streaming   | Kafka            |
| Database         | PostgreSQL       |
| Visualization    | Grafana          |
| Backend Scripts  | Python           |
| Containerization | Docker           |

---

## 🚀 Features

- Real-time data ingestion pipeline
- Optimized relational schema with indexing
- Advanced SQL analytics (15+ queries)
- Materialized views for performance
- Interactive Grafana dashboards
- Alerting and monitoring support

---

## 🗂️ Project Structure

```

├── data/                # CSV datasets
├── scripts/             # Kafka producers/consumers
├── sql/                 # Schema and analytics queries
├── dashboards/          # Grafana JSON exports
├── docker/              # Docker Compose setup
├── docs/                # Architecture diagrams
└── README.md

````

---

## 🛠️ Setup Instructions

### 1. Clone Repository
```bash
git clone <repo-url>
cd healthcare-analytics
````

### 2. Start Services (Docker)

```bash
docker-compose up -d
```

### 3. Load Initial Data

```bash
psql -U postgres -d hospital_project -f sql/schema.sql
\copy hospital_admissions FROM 'data/sample.csv' CSV HEADER;
```

### 4. Start Kafka Producer

```bash
python scripts/producer.py
```

### 5. Access Grafana

* URL: `http://localhost:3000`
* Default login: `admin/admin`

---

## 📊 Key Analytics

* Average Length of Stay (LOS)
* Revenue by Insurance Provider
* Readmission Rates
* Top Medical Conditions
* Doctor Performance Rankings
* Emergency Admission Trends

---

## ⚡ Performance Targets

* Query execution time: **< 5 seconds**
* Data ingestion latency: **< 1 second**
* Scalable to 300k+ records

---

## 🧪 Testing

* Unit testing for SQL queries
* Integration testing for Kafka pipeline
* Load testing using `pgbench`
* Data validation against source CSV

---

## 🚢 Deployment

* Fully containerized using Docker Compose
* Cloud-ready (AWS / GCP)
* Includes:

  * Kafka cluster
  * PostgreSQL database
  * Grafana dashboards

---

## 🔐 Security

* Role-based access in PostgreSQL & Grafana
* Kafka ACL configuration
* Environment variable-based secrets

---

## 📈 Future Enhancements

* Machine Learning for predictive analytics
* Integration with real EHR APIs
* Stream processing with Spark/Flink
* Advanced anomaly detection

---

## 📄 Documentation

* Architecture diagrams (in `/docs`)
* SQL scripts (`/sql`)
* Dashboard exports (`/dashboards`)

---

## 👨‍💻 Author

Developed as part of a **4-week real-time data engineering project** focused on healthcare analytics.

---

## 📜 License

This project is for educational and demonstration purposes.


