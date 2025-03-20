# PostgreSQL History Tracking

This project focuses on tracking historical health-check data in **PostgreSQL** and presenting trends over time using **Prometheus** and **Grafana**. It provides insights into database performance metrics like table growth, index bloat, and query performance.

## Features
- **Historical Health-Check Tracking**: Logs database operations (INSERT, UPDATE, DELETE) with before and after states.
- **Index Bloat Monitoring**: Visualizes index sizes, usage, and bloat over time.
- **Data Visualization**: Provides detailed dashboards using Grafana.
- **Prometheus Integration**: Continuously collects PostgreSQL metrics.
- **Efficient Troubleshooting**: Identifies inefficient indexes and tracks database trends.

---

## Tools and Their Purpose

### 1. **PostgreSQL**
- Primary database for storing operational data.
- Provides views such as `pg_stat_user_indexes` and `pg_indexes` for index statistics.
- Audit log implementation to track data changes.

### 2. **Prometheus**
- Time-series database for collecting real-time PostgreSQL metrics using `postgres_exporter`.
- Efficiently queries and stores database performance metrics.

### 3. **Grafana**
- Visualizes data from Prometheus using interactive dashboards.
- Displays database health insights, including index bloat analysis.

### 4. **Postgres Exporter**
- Collects metrics from PostgreSQL and exports them to Prometheus.
- Supports queries to monitor table growth, index bloat, and query performance.

### 5. **Audit Log Table**
- Custom audit table tracks changes to data for historical analysis.
- Logs operations (INSERT, UPDATE, DELETE) with details on the user, timestamp, and data changes.

---

## Step-by-Step Explanation

### **1. Health-Check Data Tracking**
- Operations performed on tables are captured using triggers.
- Changes are stored in an `audit_log` table with the following fields:
  - `table_name` - Table being modified.
  - `operation` - Type of operation (INSERT, UPDATE, DELETE).
  - `old_data` - Data before the change.
  - `new_data` - Data after the change.
  - `changed_by` - User who performed the operation.
  - `changed_at` - Timestamp of the operation.

#### Example Query to View Logs:
```sql
SELECT * FROM audit_log ORDER BY changed_at DESC;
```
![audit_log_table](https://github.com/user-attachments/assets/7366c70e-2635-4a5f-ac8c-9b27886d7aaa)
![audit_table](https://github.com/user-attachments/assets/999214df-15ad-4f59-9c4a-9e5af51c4a00)
![chart](https://github.com/user-attachments/assets/73f064f8-d677-4458-a9e9-748b367dbbe6)
![csv](https://github.com/user-attachments/assets/47c0c9ad-2da4-4d4a-ac73-73c5c7936a19)


---


### **2. Index Bloat Analysis**
- Indexes are monitored to detect bloat using `pg_stat_user_indexes` and `pg_indexes`.
- Metrics include:
  - **Index Size**: Amount of storage used by the index.
  - **Index Scans**: Number of times the index was used.
- Large index size with low scan count indicates potential bloat.

#### Example Query for Index Bloat:
```sql
SELECT
  psui.schemaname,
  psui.relname AS tablename,
  psui.indexrelname AS indexname,
  pg_relation_size(psui.indexrelid) AS index_size,
  psui.idx_scan AS index_scans
FROM
  pg_stat_user_indexes psui
JOIN
  pg_indexes pi ON psui.indexrelname = pi.indexname
ORDER BY
  index_size DESC;
```

#### Solution:
- Rebuild bloated indexes using the following command:
```sql
REINDEX INDEX index_name;
```

![table](https://github.com/user-attachments/assets/3a6d01be-4d20-4b37-9785-a7dcd42e2fd2)
![chart](https://github.com/user-attachments/assets/a21fdc54-40f1-4882-8c86-187b9c5d774c)



---

### **3. Visualization Using Grafana**
- Grafana displays index size, index scans, and overall database health using Prometheus as the data source.
- Dashboards are designed for clear insights and visual comparison.
- Panel options allow exporting logs for offline analysis.

---

---

## Additional Commands

- **View Database Metrics in Prometheus**
```shell
curl http://localhost:9187/metrics
```
- **Check Status of Prometheus and Exporter**
```shell
systemctl status prometheus
systemctl status postgres_exporter
```
- **Restart Services**
```shell
systemctl restart prometheus
systemctl restart postgres_exporter
```


### Metrics
![metrics](https://github.com/user-attachments/assets/9fc5b337-d9c4-4f38-99a0-1e4d84c3a489)

### Health Check Data Tracking
### Active Connections
![active_connections](https://github.com/user-attachments/assets/6ec604b1-4ac0-4845-9965-7d927bf8005b)


### Total number of commits
![commits](https://github.com/user-attachments/assets/fe467f33-cb94-4cce-b404-b94dabb955b3)


### Total number of rollbacks
![no_rollbacks](https://github.com/user-attachments/assets/74048cbd-0dac-48eb-ab00-8940abaf1f49)


### Trend Analysis
### Monitor Transaction Growth
![monitor transaction growth](https://github.com/user-attachments/assets/507ed9fe-7da0-4e94-b4a5-e1ba4274cc9a)

---

## Conclusion
This project helps database administrators efficiently monitor PostgreSQL health, detect index bloat, and track data changes. With detailed visualizations and real-time monitoring, it enables proactive maintenance, improving database performance and storage management.
