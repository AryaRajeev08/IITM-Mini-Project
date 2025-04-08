from dotenv import load_dotenv
load_dotenv()

import psycopg2
import smtplib
import os
from email.mime.text import MIMEText
from datetime import datetime

# === DB Configuration ===
conn = psycopg2.connect(
    dbname="world",
    user="admin",
    password="123",
    host="localhost",
    port="5432"
)
cur = conn.cursor()

# === Query users with password expiring in next 5 days ===
cur.execute("""
    SELECT username, email, password_expiry 
    FROM user_chk 
    WHERE password_expiry - INTERVAL '5 days' < NOW()
      AND password_expiry > NOW()
      AND email IS NOT NULL
      AND account_locked = FALSE;
""")
users = cur.fetchall()

# === Email Configuration ===
SMTP_SERVER = "smtp.gmail.com"
SMTP_PORT = 587
SENDER_EMAIL = os.environ.get("EMAIL_USER")
SENDER_PASSWORD = os.environ.get("EMAIL_PASS")

# === Setup Email Server ===
server = smtplib.SMTP(SMTP_SERVER, SMTP_PORT)
server.starttls()
server.login(SENDER_EMAIL, SENDER_PASSWORD)

# === Loop through users and send email ===
for username, email, expiry in users:
    days_left = (expiry - datetime.now().date()).days

    subject = "Your Password Will Expire Soon"
    body = f"""\
Hi {username},

Just a quick reminder: your password will expire in {days_left} day(s) on {expiry}.
Please log in and update your password to avoid getting locked out.

Thanks,  
Security Team
"""

    msg = MIMEText(body)
    msg["Subject"] = subject
    msg["From"] = SENDER_EMAIL
    msg["To"] = email

    try:
        server.sendmail(SENDER_EMAIL, email, msg.as_string())
        print(f"✅ Sent to {email}")
    except Exception as e:
        print(f"❌ Failed to send to {email}: {e}")

# === Cleanup ===
server.quit()
cur.close()
conn.close()

