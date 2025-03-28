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

## 📋 Prerequisites

- **PostgreSQL** (with `pgcrypto` and `pg_cron` extensions)
- **Superuser access** to create roles, databases, and extensions

## ⚙️ Setup Instructions

To set up this system, follow the steps below:

#### 1️⃣ Install PostgreSQL with `pgcrypto` and `pg_cron` extensions.
#### 2️⃣ Create the necessary roles, databases, and tables using the provided SQL scripts.
#### 3️⃣ Configure the cron job for automated password expiry checks.
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
### 4️⃣ Run the script
```sql
\i path\your_script_file.sql
```

## 📊 Database Schema

### 📝 Tables
- `users`: Stores user account information
- `password_history`: Tracks password change history

### 🧩 Functions
- `enforce_password_policy()`: Validates and hashes passwords
- `check_password_expiry()`: Manages password rotation and history
- `expire_old_passwords()`: Locks accounts with expired passwords


## 🛡️ Security Recommendations

- Regularly update PostgreSQL and extensions
- Use strong, unique passwords
- Monitor account activities

## 🔧 Customization

You can modify the following parameters:
- Password complexity requirements
- Password expiration interval (currently 90 days)
- Number of previous passwords to block (currently 3)

## 📸 Screen Shots
### Password Policy Check
![Password Policy Check](https://github.com/user-attachments/assets/ecaa260b-4e64-44de-a8d7-966393f35434)
### Password History Check
![Password History Check](https://github.com/user-attachments/assets/f266e77f-976b-44df-926e-b88b69c52efa)
### Vulnerable Account listing
![Vulnerable Accounts](https://github.com/user-attachments/assets/f7b7365b-b4ee-4bea-8146-b738a2f8f6d4)
### Expired Accounts
![Expired Accounts](https://github.com/user-attachments/assets/f5538a92-9222-4841-9553-89d0d367f928)


## Example SQL for Creating the Required Extensions

```sql
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS pg_cron;
```