# History Tracking Using Prometheus, PostgreSQL, and Grafana

## Features
- **Real-time Monitoring:** Track database activity and system performance.
- **Audit Logs:** Capture detailed information about database queries and changes.
- **Visual Representation:** Visualize metrics and logs using Grafana.
- **Efficient Querying:** Perform SQL queries on audit logs for insights.
- **Export Logs:** Export audit data to CSV files for reporting.

---

## Tools Used and Their Functions

### 1. **Prometheus**
- **Purpose:** Prometheus is used for collecting and storing metrics from various services.
- **Function:**
  - Scrapes metrics from PostgreSQL using exporters.
  - Monitors system performance (CPU, memory, storage).
  - Provides a queryable database for time-series data.
  - Role in History Tracking:** Tracks database metrics and monitors system health.

### 2. **PostgreSQL**
- **Purpose:** PostgreSQL serves as the database management system where all data and logs are stored.
- **Function:**
  - Records database changes and logs through audit tables.
  - Stores the application and system-level data.
  - Provides SQL query access to audit logs.
  - Role in History Tracking:** Stores audit logs for further analysis.

### 3. **PostgreSQL Exporter**
- **Purpose:** PostgreSQL Exporter is used to export PostgreSQL metrics for Prometheus.
- **Function:**
  - Connects to PostgreSQL and extracts database metrics.
  - Sends data to Prometheus for monitoring.
  - Role in History Tracking:** Facilitates real-time tracking of database state and performance.

### 4. **Grafana**
- **Purpose:** Grafana is a visualization tool for creating dashboards and graphs.
- **Function:**
  - Connects to Prometheus and PostgreSQL.
  - Visualizes metrics, logs, and query results.
  - Provides the option to export logs in CSV format.
  - Role in History Tracking:** Displays real-time and historical data using customizable dashboards.

---

## Usage Overview
1. **Metrics Monitoring:** Prometheus scrapes data from PostgreSQL Exporter and stores it.
2. **Data Visualization:** Grafana queries Prometheus and PostgreSQL to display relevant data.
3. **Audit Analysis:** PostgreSQL provides audit logs for tracking database changes.
4. **Exporting Logs:** Users can query logs via Grafana and export them as CSV files.

This integrated system ensures efficient and transparent database history tracking with easy access to log data and visual reports.

