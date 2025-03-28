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

1. Install PostgreSQL with `pgcrypto` and `pg_cron` extensions.
2. Create the necessary roles, databases, and tables using the provided SQL scripts.
3. Configure the cron job for automated password expiry checks.

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

### Email Reminder

A query is set up to identify users who need to be reminded to renew their passwords, and email notifications are sent out accordingly.

## Screen Shots
![Password Policy Check](https://github.com/user-attachments/assets/ecaa260b-4e64-44de-a8d7-966393f35434)

![Password History Check](https://github.com/user-attachments/assets/f266e77f-976b-44df-926e-b88b69c52efa)

![Vulnerable Accounts](https://github.com/user-attachments/assets/f7b7365b-b4ee-4bea-8146-b738a2f8f6d4)

![Expired Accounts](https://github.com/user-attachments/assets/f5538a92-9222-4841-9553-89d0d367f928)

## Example SQL for Creating the Required Extensions

```sql
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS pg_cron;







