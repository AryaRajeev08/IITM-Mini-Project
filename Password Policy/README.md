# PostgreSQL User Management System

This PostgreSQL script implements a secure user management system with enforced password policies, password expiration, and history tracking. It includes triggers, functions, and automated cron jobs to maintain security standards for stored user credentials.

## Features

- **Strict Password Policy**: Ensures passwords meet length and complexity requirements.
- **Password Expiry**: Users must change passwords every 90 days.
- **Password History Check**: Prevents reuse of the last 3 passwords.
- **Automatic Expiry Lock**: Locks accounts with expired passwords.
- **Scheduled Expiry Check**: Uses `pg_cron` to automate password expiry checks.
- **Email Reminder Query**: Identifies users needing password renewal reminders.

## Prerequisites

- **PostgreSQL** (with `pgcrypto` and `pg_cron` extensions)
- **Superuser access** to create roles, databases, and extensions

## Setup Instructions

To set up this system, follow the steps below:

#### 1️⃣ Install PostgreSQL with `pgcrypto` and `pg_cron` extensions.
#### 2️⃣ Create the necessary roles, databases, and tables using the provided SQL scripts.
#### 3️⃣ Configure the cron job for automated password expiry checks.
##### Configure `pg_cron` (for Automating Jobs)

1. To enable `pg_cron`, ensure the extension is loaded by adding this to postgresql.conf:
```bash
sudo nano /etc/postgresql/15/main/postgresql.conf   # Adjust version accordingly
```
2. Add the following lines at the end:
```bash
shared_preload_libraries = 'pg_cron'
cron.database_name = 'postgres'    #your database name
```
3. Restart PostgreSQL to apply changes:
```bash
sudo systemctl restart postgresql
```
### 4️⃣ Run the script
```sql
\i path\your_script_file.sql
```

## SQL Script Overview

### Password Policy Enforcement

The script ensures that:

- Password length is at least 12 characters.
- Password contains at least one uppercase letter, one lowercase letter, one number, and one special character.

### Password Expiry

Users will be required to change their passwords every 90 days. Once expired, their accounts will be locked until the password is updated.

### Password History Check

The system tracks the last 3 passwords and prevents users from reusing them.

### Automated Expiry Lock

Accounts with expired passwords will be automatically locked by a trigger.

### Scheduled Expiry Check with `pg_cron`

We use `pg_cron` to automate password expiry checks at scheduled intervals.


## Example SQL for Creating the Required Extensions

```sql
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS pg_cron;
```

### Email Reminder

A query is set up to identify users who need to be reminded to renew their passwords, and email notifications are sent out accordingly.

## Screen Shots
### Password Policy Check
![Password Policy Check](https://github.com/user-attachments/assets/ecaa260b-4e64-44de-a8d7-966393f35434)
### Password History Check
![Password History Check](https://github.com/user-attachments/assets/f266e77f-976b-44df-926e-b88b69c52efa)
### Vulnerable Account listing
![Vulnerable Accounts](https://github.com/user-attachments/assets/f7b7365b-b4ee-4bea-8146-b738a2f8f6d4)
### Expired Accounts
![Expired Accounts](https://github.com/user-attachments/assets/f5538a92-9222-4841-9553-89d0d367f928)