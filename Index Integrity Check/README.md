# Index Integrity Check

## Overview

This folder contains SQL scripts and supporting files related to **index integrity checks** in PostgreSQL. Ensuring index integrity is crucial for maintaining database performance and consistency.

## Files in This Folder

- **IndexIntegrity.sql** - SQL script to check for index corruption and integrity issues.
- **Corruption.png** - Image showing an example of a corrupted index.
- **Corruption_rectified.png** - Image showing fixed index.
- **Index_table.png** - Image showing the indexname and tablename.
- **Job_scheduled.png** - Screenshot of a scheduled job for automated integrity checks.
- **Preview_jobschedule.png** - Example preview of scheduled jobs.

## How to Use

### Running the Automated Integrity Check

1. Open your PostgreSQL database.
2. Run the SQL script:
   ```sql
   \i IndexIntegrity.sql
   ```
3. The script will automatically detect and fix any corrupted indexes.
4. Review the output logs to confirm successful repairs.

## Function Used for Fixing Corruption

The SQL script includes the `check_index_integrity()` function, which:
- Iterates through all indexes in the database.
- Uses `bt_index_check()` to verify index integrity.
- If corruption is detected:
  - Logs the issue in the `corruption_logs` table.
  - Attempts to fix the corruption by reindexing the affected index using:
    ```sql
    REINDEX INDEX index_name;
    ```
- If reindexing is insufficient, the index can be dropped and recreated manually if necessary.
- Outputs messages indicating whether corruption was found or not.


## Automating Index Checks

- The process of detecting and fixing corruption is fully automated within `IndexIntegrity.sql`.
- Use **scheduled jobs** to execute the script periodically.
- Refer to **Job_scheduled.png** and **Preview_jobschedule.png** for guidance on setting up automation.

## Contact

For any issues or improvements, please open an issue in the GitHub repository.

