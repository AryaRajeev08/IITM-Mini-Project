<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PostgreSQL User Management</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
            background-color: #f4f4f4;
            color: #333;
            padding: 20px;
        }
        h1, h2, h3 {
            color: #2c3e50;
        }
        ul {
            margin-left: 20px;
        }
        .feature-list {
            list-style-type: disc;
        }
        .code {
            background-color: #2d3e50;
            color: white;
            padding: 5px;
            border-radius: 3px;
            font-family: monospace;
        }
        .note {
            background-color: #f9e2e2;
            border-left: 5px solid #e74c3c;
            padding: 10px;
            margin: 10px 0;
        }
        .prerequisite-list {
            list-style-type: square;
        }
    </style>
</head>
<body>
    <h1>PostgreSQL User Management System</h1>
    <p>This PostgreSQL script implements a secure user management system with enforced password policies, password expiration, and history tracking. It includes triggers, functions, and automated cron jobs to maintain security standards for stored user credentials.</p>

    <h2>Features</h2>
    <ul class="feature-list">
        <li><strong>Strict Password Policy:</strong> Ensures passwords meet length and complexity requirements.</li>
        <li><strong>Password Expiry:</strong> Users must change passwords every 90 days.</li>
        <li><strong>Password History Check:</strong> Prevents reuse of the last 3 passwords.</li>
        <li><strong>Automatic Expiry Lock:</strong> Locks accounts with expired passwords.</li>
        <li><strong>Scheduled Expiry Check:</strong> Uses <code>pg_cron</code> to automate password expiry checks.</li>
        <li><strong>Email Reminder Query:</strong> Identifies users needing password renewal reminders.</li>
    </ul>

    <h2>Prerequisites</h2>
    <ul class="prerequisite-list">
        <li><strong>PostgreSQL</strong> (with <code>pgcrypto</code> and <code>pg_cron</code> extensions)</li>
        <li><strong>Superuser access</strong> to create roles, databases, and extensions</li>
    </ul>

    <h2>Setup Instructions</h2>
    <p>To set up this system, follow the steps below:</p>
    <ol>
        <li>Install PostgreSQL with <code>pgcrypto</code> and <code>pg_cron</code> extensions.</li>
        <li>Create the necessary roles, databases, and tables using the provided SQL scripts.</li>
        <li>Configure the cron job for automated password expiry checks.</li>
        <li>Set up email reminders using your preferred SMTP server.</li>
    </ol>

    <h2>SQL Script Overview</h2>
    <h3>Password Policy Enforcement</h3>
    <p>The script ensures that:</p>
    <ul>
        <li>Password length is at least 12 characters.</li>
        <li>Password contains at least one uppercase letter, one lowercase letter, one number, and one special character.</li>
    </ul>

    <h3>Password Expiry</h3>
    <p>Users will be required to change their passwords every 90 days. Once expired, their accounts will be locked until the password is updated.</p>

    <h3>Password History Check</h3>
    <p>The system tracks the last 3 passwords and prevents users from reusing them.</p>

    <h3>Automated Expiry Lock</h3>
    <p>Accounts with expired passwords will be automatically locked by a trigger.</p>

    <h3>Scheduled Expiry Check with <code>pg_cron</code></h3>
    <p>We use <code>pg_cron</code> to automate password expiry checks at scheduled intervals.</p>

    <h3>Email Reminder</h3>
    <p>A query is set up to identify users who need to be reminded to renew their passwords, and email notifications are sent out accordingly.</p>

    <h2>Example SQL for Creating the Required Extensions</h2>
    <pre class="code">
    CREATE EXTENSION IF NOT EXISTS pgcrypto;
    CREATE EXTENSION IF NOT EXISTS pg_cron;
    </pre>

    <h2>Contact</h2>
    <p>If you have any questions or need further assistance, feel free to reach out to the repository owner.</p>

    <h3>License</h3>
    <p>This project is licensed under the MIT License.</p>
</body>
</html>
