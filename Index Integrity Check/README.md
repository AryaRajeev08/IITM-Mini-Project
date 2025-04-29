# PostgreSQL Index Integrity Check System  

This PostgreSQL script implements an **automated index integrity management system** with scheduled checks, logging, and self-healing mechanisms. It ensures database indexes remain **consistent and corruption-free** using `amcheck` for verification and `pg_cron` for automated scheduling.  

---

## Features  

### 1️⃣ **Automated Index Integrity Checks**  
- Periodically scans **all indexes** for corruption.  
- Uses `bt_index_check()` to verify index consistency.  

### 2️⃣ **Corruption Logging**  
- Stores **corrupted index details** in a dedicated table.  
- Includes timestamp and affected table name.  

### 3️⃣ **Self-Healing Mechanism**  
- Automatically **rebuilds** corrupted indexes.  
- Uses `REINDEX INDEX` to restore integrity.  

### 4️⃣ **Scheduled Maintenance**  
- Uses `pg_cron` to **run checks daily at midnight**.  
- Reduces manual intervention for database maintenance.  

---

## Prerequisites  

Before using this system, ensure the following requirements are met:  

👉**PostgreSQL 12+** (or higher)  
👉 Installed Extensions: `amcheck` (for index integrity checks), `pg_cron` (for scheduling jobs)  
👉 **Superuser Privileges** (to create extensions & schedule jobs)  

---

## ⚙Setup Instructions  

### **1️⃣ Install Required Extensions**  

```sql
CREATE EXTENSION IF NOT EXISTS amcheck;  -- Enables index integrity checks
CREATE EXTENSION IF NOT EXISTS pg_cron;  -- Enables scheduling of maintenance jobs
```

---

### **2️⃣ Configure `pg_cron` for Automated Checks**  

> 🔹 **Enable `pg_cron`** by adding this to `postgresql.conf`:  
```bash
sudo nano /etc/postgresql/14/main/postgresql.conf   # Adjust version if needed
```
> 🔹 Add the following lines at the end:  
```bash
shared_preload_libraries = 'pg_cron'
cron.database_name = 'world'  # Set to your database name
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

## Database Schema  

### **Tables**  

| Table Name         | Description |
|--------------------|-------------|
| `corruption_logs` | Stores corruption details when detected |


---

### **Functions**  

#### `check_index_integrity()`
- Scans all indexes in the database.  
- Detects corruption using `bt_index_check()`.  
- Logs corrupted indexes in `corruption_logs`.  
- Rebuilds corrupted indexes automatically.  


---

### **4️⃣ Schedule Automatic Index Integrity Checks**  

We use `pg_cron` to run `check_index_integrity()`.



## 🔍 **Usage**  

### **Manually Check for Corrupted Indexes**  
### **View Scheduled Jobs**  

---

## **Best Practices & Security Recommendations**  

📌 Regularly **monitor `corruption_logs`** to identify persistent issues.  
📌 Keep PostgreSQL and extensions **up to date** for better performance.  
📌 Schedule **manual index checks** periodically for verification.  
📌 Ensure **backup policies** are in place before making changes.  

---

## 📸 Screenshots

1. The index:

![indexname](https://github.com/user-attachments/assets/f0fa4fcb-58bf-4f69-a2ed-ccc86feefc45)

2. The corruption displayed:
   
![corrupted](https://github.com/user-attachments/assets/f5ab18ee-1fb2-4d4c-8904-25bc38246b9f)
  
3. The exexution time:

![exec_time](https://github.com/user-attachments/assets/64bad48c-4c45-4318-b442-d76f1c4f249f)


4. Index size:

![indexsize](https://github.com/user-attachments/assets/13bc52ef-dec6-443f-8767-b2297c80f654)


5. Job scheduled:
 
![job](https://github.com/user-attachments/assets/7a92b239-b57b-49cb-a068-66ff3580b685)











