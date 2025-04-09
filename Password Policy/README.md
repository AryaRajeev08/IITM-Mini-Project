# 🔐 PostgreSQL Password Policy Enhancement

This PostgreSQL script implements a secure user management system with enforced password policies, password expiration, and history tracking. It includes triggers, functions, and automated cron jobs to maintain security standards for stored user credentials.

## 🌟 Features

### 1. 🔑 User Authentication
- Secure user creation with encrypted passwords
- Mandatory strong password requirements
- Automatic password hashing using bcrypt

### 2. 🛡️ Password Policy Enforcement
The script enforces strict password complexity rules:
- Minimum length of 12 characters
- Requires at least:
  - One uppercase letter
  - One lowercase letter
  - One number
  - One special character (`!@#$%^&*()`)

### 3. 🔄 Password History and Rotation
- Prevents password reuse (last 3 passwords)
- Automatic 90-day password expiration
- Prevents repeated password submissions

### 4. 🚨 Account Security
- Automatic account locking for expired passwords
- Password expiry tracking
- Scheduled password expiration checks

### 5. 📧 Email Notifications
- Automated email alerts for upcoming password expirations
- Configurable notification period (currently 5 days before expiration)
- Daily scheduled checks for expiring passwords

## 📋 Prerequisites

- **PostgreSQL** (with `pgcrypto` and `pg_cron` extensions)
- **Superuser access** to create roles, databases, and extensions
- **Python** with `psycopg2` and `python-dotenv` packages
- **SMTP access** for sending email notifications

## ⚙️ Setup Instructions

To set up this system, follow the steps below:

#### 1️⃣ Install PostgreSQL with `pgcrypto` and `pg_cron` extensions.
#### 2️⃣ Configure the cron job for automated password expiry checks.
> ##### Configure `pg_cron` (for Automating Jobs)
>
>1. To enable `pg_cron`, ensure the extension is loaded by adding this to postgresql.conf:
```bash
sudo nano /etc/postgresql/15/main/postgresql.conf   # Adjust version accordingly
```
>2. Add the following lines at the end:
```bash
shared_preload_libraries = 'pg_cron'
cron.database_name = 'postgres'    #your database name
```
>3. Restart PostgreSQL to apply changes:
```bash
sudo systemctl restart postgresql
```
>

#### 3️⃣ Run the script
```sql
\i path\your_script_file.sql
```

## 📧 Email Notification Setup

#### 1️⃣ Install required Python packages
```bash
pip install psycopg2 python-dotenv
```

#### 2️⃣ Create a `.env` file for email credentials
```
EMAIL_USER=your_email@gmail.com
EMAIL_PASS=your_app_password
```

> **Note:** For Gmail, you'll need to use an App Password instead of your regular password. Visit [Google Account Security Settings](https://myaccount.google.com/security) to set up 2FA and generate an App Password.

#### 3️⃣ Configure crontab to run the email notification script daily
```bash
# Open crontab editor
crontab -e

# Add this line to run the script daily at 9 AM
0 9 * * * python3 "/path/to/your/send_remainder.py" >> "/path/to/your/email_log.txt" 2>&1
```

## 📊 Database Schema

### 📝 Tables
- `users`: Stores user account information
- `password_history`: Tracks password change history

### 🧩 Functions
- `enforce_password_policy()`: Validates and hashes passwords
- `check_password_expiry()`: Manages password rotation and history
- `expire_old_passwords()`: Locks accounts with expired passwords

## 📧 Email Notification System

The system automatically checks for passwords expiring in the next 5 days and sends email notifications to affected users. The notification script:

1. Connects to the PostgreSQL database
2. Identifies users with passwords expiring within 5 days
3. Sends personalized email notifications with expiration details
4. Logs successes and failures

### 🛠️ Configuration Options

- Modify the notification period by changing the `INTERVAL '5 days'` value
- Customize email content and formatting in the script
- Adjust the schedule by modifying the crontab entry

## 🛡️ Security Recommendations

- Regularly update PostgreSQL and extensions
- Use strong, unique passwords
- Monitor account activities
- Secure your `.env` file with appropriate permissions
- Use TLS/SSL for database connections in production

## 🔧 Customization

You can modify the following parameters:
- Password complexity requirements
- Password expiration interval (currently 90 days)
- Number of previous passwords to block (currently 3)
- Email notification period (currently 5 days before expiration)
- Email template and content

## 📸 Screen Shots
### Password Policy Check
![Password Policy Check](https://github.com/user-attachments/assets/ecaa260b-4e64-44de-a8d7-966393f35434)
### Password History Check
![Password History Check](https://github.com/user-attachments/assets/f266e77f-976b-44df-926e-b88b69c52efa)
### Vulnerable Account listing
![Vulnerable Accounts](https://github.com/user-attachments/assets/f7b7365b-b4ee-4bea-8146-b738a2f8f6d4)
### Expired Accounts
![Expired Accounts](https://github.com/user-attachments/assets/f5538a92-9222-4841-9553-89d0d367f928)
### Email Notification
![Email Notification](https://github.com/user-attachments/assets/22c25a65-7971-4991-9d69-0b692a412bee)

## Example SQL for Creating the Required Extensions

```sql
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS pg_cron;
```