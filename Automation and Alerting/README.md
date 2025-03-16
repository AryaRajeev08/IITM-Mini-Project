# **PostgreSQL Monitoring with Prometheus - Health Collector and Email Sender**

## **Overview**

This project is designed to monitor PostgreSQL performance metrics and send health reports. The monitoring system collects key PostgreSQL metrics, exposes them to Prometheus for scraping, and sends health status updates through email using a cron job. 

### **Key Components**

1. **health_collector.go**
2. **email_sender.go**

---

## **Health Collector (health_collector.go)**

The `health_collector.go` file collects and exposes key PostgreSQL performance metrics to Prometheus for continuous monitoring.

### **Key Metrics Collected:**

- **CPU Usage:** Monitors the CPU usage of the PostgreSQL process.
- **Replication Lag:** Monitors the delay between the primary and standby databases.
- **Slow Query Time:** Monitors the execution time of the slowest query in PostgreSQL.

### **What It Does:**

- **Collects Metrics:**
    - Gets CPU usage via a shell command.
    - Queries the PostgreSQL database to get replication lag.
    - Retrieves the slowest query execution time.
  
- **Exposes Metrics to Prometheus:**
    - Formats the collected metrics for Prometheus to scrape and store.
  
- **Alerts:**
    - **CPU Usage Alert:** Triggered if CPU usage exceeds 70%.
    - **Replication Lag Alert:** Triggered if replication lag exceeds 10 seconds.
    - **Slow Query Alert:** Triggered if slow query execution time exceeds 3 seconds.

### **How to Use `health_collector.go`:**

1. Add this file to the collector directory in the `postgres_exporter` source code.
2. Update the following configuration files:
    - `prometheus.yml`
    - `alert_rules.yml`
    - `alertmanager.yml`
   
3. **Run the following services:**
    - **Prometheus**: Scrapes the metrics.
    - **Alertmanager**: Sends alerts when conditions are met.
    - **PostgreSQL Exporter**: Exposes PostgreSQL metrics.

Once all services are up and running, you can view the alerts and metrics in the Prometheus UI. If the alert conditions are met, Alertmanager will send notifications (e.g., via email).


![postgresexporter_metrics](https://github.com/user-attachments/assets/194d6a8d-06d6-41c6-9ca0-11673745d0d0)

![prometheus](https://github.com/user-attachments/assets/2dd0f887-8a3a-4440-bc42-fc9f584eb54e)

![slowquerydetected](https://github.com/user-attachments/assets/93dd32e3-acc7-4e72-bdea-c0e64219cc54)

![alertmanagerdealswithslowquery](https://github.com/user-attachments/assets/4749db1d-8810-47e9-a99a-b2f38ff1c539)

![emailslowquery](https://github.com/user-attachments/assets/6b05bf0a-2fbd-47d2-ae7f-18fb5d8a2d13)

![emailhighcpuusage](https://github.com/user-attachments/assets/34594765-f8a0-4846-9f35-e464ce71b00c)


---

## **Email Sender (email_sender.go)**

The `email_sender.go` is a tool that collects PostgreSQL database statistics and sends an email with the health status report.

### **Key Functionalities:**

1. **Collects PostgreSQL Metrics:**
    - **Database Sizes:** Queries PostgreSQL to retrieve the sizes of all databases.
    - **Table Sizes:** Queries PostgreSQL to retrieve the sizes of all tables.
    - **Query Statistics:** Fetches the top 5 slowest queries using the `pg_stat_statements` extension, including execution time and the number of calls.

2. **Health Report:**
    - The collected metrics are organized into a `HealthCheck` struct with:
        - **Database Sizes**
        - **Table Sizes**
        - **Query Stats (slow queries)**

3. **Email Functionality:**
    - The metrics are formatted into a JSON report.
    - The JSON report is sent via email using SMTP (configured with Gmail’s SMTP server).
    - The email is sent to a predefined recipient (`TO_EMAIL`).


![dailyhealcheckreportemail](https://github.com/user-attachments/assets/83346fa9-e1d6-4bf8-90f5-61f495b35514)


### **How to Use `email_sender.go`:**

1. **Compilation:**
    - Add the `email_sender.go` file to your desired directory.
    - Compile the program using:
      ```bash
      go build -o email_sender.go
      ```

2. **Automated Daily Reports Using Cron:**
    - Schedule the email report to be sent daily by editing the cron configuration:
      ```bash
      crontab -e
      ```
    - Add the following cron job to send an email every day at 8 AM:
      ```bash
      0 8 * * * /path/to/email_sender
      ```
    - This will run the `email_sender` program every day at the specified time.

---

## **Configuration Files:**

1. **`prometheus.yml`:**
    - Add the `postgres_exporter` job in the `scrape_configs` section.
    - Example:
      ```yaml
      scrape_configs:
        - job_name: 'postgres'
          static_configs:
            - targets: ['localhost:9187']
      ```

2. **`alert_rules.yml`:**
    - Add custom alerting rules based on CPU usage, replication lag, or slow queries.
    - Example:
      ```yaml
      groups:
        - name: PostgreSQL Alerts
          rules:
            - alert: HighCPUUsage
              expr: postgres_cpu_usage > 70
              for: 1m
            - alert: ReplicationLag
              expr: postgres_replication_lag > 10
              for: 1m
            - alert: SlowQuery
              expr: postgres_slowest_query_time > 3
              for: 1m
      ```

3. **`alertmanager.yml`:**
    - Configure Alertmanager to send email notifications based on the alerts defined in `alert_rules.yml`.
    - Example:
      ```yaml
      receivers:
        - name: 'email-notifications'
          email_configs:
            - to: 'your-email@example.com'
              from: 'your-email@example.com'
              smarthost: 'smtp.gmail.com:587'
              auth_username: 'your-email@example.com'
              auth_password: 'your-email-password'
              send_resolved: true
      ```

---

## **Conclusion**

By using `health_collector.go` and `email_sender.go`, you can monitor the performance of your PostgreSQL databases and automatically receive health reports via email. This system integrates PostgreSQL performance metrics with Prometheus and sends alerts based on predefined conditions, ensuring your database is always performing optimally.

---

If you need further assistance or customization, feel free to contribute or open an issue in the repository.
