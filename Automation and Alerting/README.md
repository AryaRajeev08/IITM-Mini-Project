 *** **HEALTH-COLLECTOR** ***

The health_collector.go collects and exposes PostgreSQL performance metrics to Prometheus for monitoring. Here's a simplified breakdown:
Key Metrics Collected:
CPU Usage of the PostgreSQL process.
Replication Lag: How much delay there is between the primary and standby database.
Slow Query Time: Time taken by the slowest query in PostgreSQL.
What It Does:
Collects Metrics:

Gets CPU usage via a shell command.
Queries the PostgreSQL database for replication lag.
Gets the slowest query time from the database.
Exposes Metrics to Prometheus:

These metrics are formatted for Prometheus to scrape (fetch and store) for monitoring.
Alerts:

Logs alerts if:
CPU usage exceeds 70%.
Replication lag exceeds 10 seconds.
Slow query execution time exceeds 3 seconds.

////How to use it \\\\
Add this file to the collector directory in the postgres_exporter source code.
Also update the prometheus.yml, alert_rules.yml and alertmanager.yml file.

Once everything is set, run prometheus, alertmanager and postgres_exporter and all the alert rules will be shown in the prometheus ui and if the 
alert conditions are met, the alertmanager will alert the user through an email.

*** ***EMAIL_SENDER** ***

The email_sender.go is designed to collect statistics from a PostgreSQL database and send the health status in the form of an email. 
It includes the following key functionalities:

1. Collecting PostgreSQL Metrics
Database Sizes: It queries PostgreSQL to get the sizes of all databases.
Table Sizes: It queries PostgreSQL to get the sizes of all tables in the database.
Query Statistics: It fetches the top 5 queries based on execution time using the pg_stat_statements extension, including total execution time and the number of calls.
2. Health Report
The metrics are organized into a HealthCheck struct, which includes:
Database Sizes: A list of database sizes.
Table Sizes: A list of table sizes.
Query Stats: A list of the top 5 slow queries with their execution times and call counts.
3. Sending an Email
The collected metrics are then formatted into a JSON report.
This JSON report is sent as the body of an email using SMTP (with Gmail's SMTP server in this case).
The email is sent to a predefined recipient email address (TO_EMAIL).

////How to use it\\\\
Add this to your dezired directory and compile it using :  go build -o email_sender.go
To send an automated daily report, you can use a cron job : Edit the cron configuration file to schedule the program using crontab -e
Add "minute hour day_of_month month day_of_week" command in the crontab
This will automatically send health reports to the user.


