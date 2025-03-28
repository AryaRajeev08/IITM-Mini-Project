# 🛠️ PostgreSQL Index Integrity Check System  

This PostgreSQL script implements an **automated index integrity management system** with scheduled checks, logging, and self-healing mechanisms. It ensures database indexes remain **consistent and corruption-free** using `amcheck` for verification and `pg_cron` for automated scheduling.  

---

## 🌟 Features  

### 1️⃣ 🏢 **Automated Index Integrity Checks**  
- Periodically scans **all indexes** for corruption.  
- Uses `bt_index_check()` to verify index consistency.  

### 2️⃣ 📝 **Corruption Logging**  
- Stores **corrupted index details** in a dedicated table.  
- Includes timestamp and affected table name.  

### 3️⃣ 🔄 **Self-Healing Mechanism**  
- Automatically **rebuilds** corrupted indexes.  
- Uses `REINDEX INDEX` to restore integrity.  

### 4️⃣ 🕒 **Scheduled Maintenance**  
- Uses `pg_cron` to **run checks daily at midnight**.  
- Reduces manual intervention for database maintenance.  

### 5️⃣ 📊 **Manual Integrity Verification**  
- Administrators can **manually run** checks at any time.  
- View previous corruption logs easily.  

---

## 👌 Prerequisites  

Before using this system, ensure the following requirements are met:  

👉 **PostgreSQL 12+** (or higher)  
👉 Installed Extensions: `amcheck` (for index integrity checks), `pg_cron` (for scheduling jobs)  
👉 **Superuser Privileges** (to create extensions & schedule jobs)  

---

## ⚙️ Setup Instructions  

### **1️⃣ Install Required Extensions**  

```sql
CREATE EXTENSION IF NOT EXISTS amcheck;  -- Enables index integrity checks
CREATE EXTENSION IF NOT EXISTS pg_cron;  -- Enables scheduling of maintenance jobs
```

---

### **2️⃣ Configure `pg_cron` for Automated Checks**  

> 🔹 **Enable `pg_cron`** by adding this to `postgresql.conf`:  
```bash
sudo nano /etc/postgresql/15/main/postgresql.conf   # Adjust version if needed
```
> 🔹 Add the following lines at the end:  
```bash
shared_preload_libraries = 'pg_cron'
cron.database_name = 'index_checker'  # Set to your database name
```
> 🔹 Restart PostgreSQL to apply changes:  
```bash
sudo systemctl restart postgresql
```

---

### **3️⃣ Run the Script**  

```sql
\i path/to/your_script.sql
```

---

## 📊 Database Schema  

### 📝 **Tables**  

| Table Name         | Description |
|--------------------|-------------|
| `corruption_logs` | Stores corruption details when detected |


---

### 🧙️ **Functions**  

#### ✅ `check_index_integrity()`
- Scans all indexes in the database.  
- Detects corruption using `bt_index_check()`.  
- Logs corrupted indexes in `corruption_logs`.  
- Rebuilds corrupted indexes automatically.  


---

### 🕒 **4️⃣ Schedule Automatic Index Integrity Checks**  

We use `pg_cron` to run `check_index_integrity()`.



## 🔍 **Usage**  

### ✅ **Manually Check for Corrupted Indexes**  
### ✅ **View Scheduled Jobs**  

---

## 🛡️ **Best Practices & Security Recommendations**  

📌 Regularly **monitor `corruption_logs`** to identify persistent issues.  
📌 Keep PostgreSQL and extensions **up to date** for better performance.  
📌 Schedule **manual index checks** periodically for verification.  
📌 Ensure **backup policies** are in place before making changes.  

---

## 📸 Screenshots

The table and the index:
![Index_table](https://github.com/user-attachments/assets/488a78e4-ab6f-494e-bb0e-e12ade49de98)

The corruption displayed:
![Corruption](https://github.com/user-attachments/assets/e0d2a2df-5a4d-49d6-bdb6-1d21ea573a6c)

The corruption rectified:
![Corruption_rectified](https://github.com/user-attachments/assets/3eca0dfa-ba9c-41be-a4fa-ef30a72e2f53)

Job scheduled:
![Job_scheduled](https://github.com/user-attachments/assets/e9cc1e56-54f5-4e58-a2cf-9d5c750a0d5c)

Job schedule preview:
![Preview_jobschedule](https://github.com/user-attachments/assets/a813f29d-3d9f-44b5-a363-64de6dfa2d2f)










