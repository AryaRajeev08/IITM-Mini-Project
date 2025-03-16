*** **Overview** ***

This PostgreSQL script implements a secure user management system with enforced password policies, password expiration, and history tracking. It includes triggers, functions, and automated cron jobs to maintain security standards for stored user credentials.

*** **Features** ***

-Strict Password Policy: Ensures passwords meet length and complexity requirements.
-Password Expiry: Users must change passwords every 90 days.
-Password History Check: Prevents reuse of the last 3 passwords.
-Automatic Expiry Lock: Locks accounts with expired passwords.
-Scheduled Expiry Check: Uses pg_cron to automate password expiry checks.
Email Reminder Query: Identifies users needing password renewal reminders.

*** **Prerequisites** ***

PostgreSQL (with pgcrypto and pg_cron extensions)
Superuser access to create roles, databases, and extensions
