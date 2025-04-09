# PostgreSQL Database Security, Integrity, and Monitoring System

## Overview
This project enhances PostgreSQL security, index integrity, and monitoring by implementing advanced database management features. It ensures strict password policies, automated index integrity checks, historical performance tracking, and real-time monitoring using Prometheus and Grafana.

## Features

### 1️⃣ PostgreSQL Password Policy Enhancement
This module implements a secure user management system with enforced password policies, expiration tracking, and history retention. It strengthens security by preventing weak passwords, enforcing complexity rules, and implementing automatic expiration and rotation policies.

#### Key Functionalities:
- **User Authentication:** Secure user creation with encrypted passwords and automatic password hashing.
- **Password Policy Enforcement:** Enforces minimum length, uppercase, lowercase, numeric, and special character requirements.
- **Password History and Rotation:** Blocks reuse of previous passwords and ensures automatic expiration.
- **Account Security:** Automatically locks accounts with expired passwords and tracks password expiry.
- **Email Notifications:** Automated email alerts for upcoming password expirations.

### 2️⃣ PostgreSQL Index Integrity Check System
This feature ensures the integrity of database indexes by automating corruption checks, logging issues, and rebuilding corrupted indexes when necessary.

#### Key Functionalities:
- **Automated Index Integrity Checks:** Periodically scans indexes for corruption using verification tools.
- **Corruption Logging:** Stores details of corrupted indexes, including timestamps and affected table names.
- **Self-Healing Mechanism:** Automatically rebuilds corrupted indexes to restore database integrity.
- **Scheduled Maintenance:** Runs integrity checks at predefined intervals to minimize manual intervention.

### 3️⃣ PostgreSQL Monitoring with Prometheus - Health Collector & Alerts
This module provides real-time monitoring and alerting for PostgreSQL databases. It collects performance metrics, exposes them to Prometheus, and triggers alerts based on predefined thresholds.

#### Key Functionalities:
- **Health Metric Collection:** Tracks CPU usage, replication lag, and slow query execution times.
- **Prometheus Integration:** Exposes collected metrics for monitoring via Prometheus.
- **Alerting System:** Generates alerts when thresholds are exceeded for CPU usage, replication lag, or slow queries.
- **Email Notifications:** Sends scheduled PostgreSQL health reports via email, detailing database size, table sizes, and query statistics.

### 4️⃣ PostgreSQL History Tracking
This feature logs historical health-check data and provides insights into database trends over time using Prometheus and Grafana.

#### Key Functionalities:
- **Health-Check Tracking:** Logs database operations (INSERT, UPDATE, DELETE) with before-and-after states.
- **Index Bloat Monitoring:** Tracks and visualizes index growth, usage, and efficiency.
- **Grafana Dashboards:** Displays key performance metrics through interactive visualizations.
- **PostgreSQL Exporter:** Collects and sends database statistics to Prometheus for real-time analysis.
- **Audit Log Table:** Maintains detailed records of database modifications, including timestamps and users responsible for changes.

## Benefits
✅ **Enhanced Security:** Enforces strong password policies and protects user accounts.
✅ **Automated Maintenance:** Reduces manual effort with scheduled index checks and password expiration management.
✅ **Improved Database Health:** Prevents index corruption and ensures consistent performance.
✅ **Real-Time Monitoring:** Provides continuous insights into database activity and health.
✅ **Historical Analysis:** Tracks long-term trends for database growth, index performance, and operational efficiency.

## Conclusion
This project brings together critical database security, integrity, and monitoring features, ensuring PostgreSQL remains reliable, secure, and optimized for high-performance applications.

