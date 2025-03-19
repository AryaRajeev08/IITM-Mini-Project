# Index Integrity Check

## Overview

This folder contains SQL scripts and supporting files related to **index integrity checks** in PostgreSQL. Ensuring index integrity is crucial for maintaining database performance and consistency.

## Files in This Folder

- **IndexIntegrity.sql** - SQL script to check for index corruption and integrity issues.
- **Corruptio.png** - Image showing an example of a corrupted index.
- **Corruption\_rectified.png** - Image showing fixed index.
- **Index\_table.png** - Image showing the indexname and tablename.
- **Job\_scheduled.png** - Screenshot of a scheduled job for automated integrity checks.
- **Preview\_jobschedule.png** - Example preview of scheduled jobs.

## How to Use

### Running the Integrity Check

1. Open your PostgreSQL database.
2. Run the SQL script:
   ```sql
   \\i IndexIntegrity.sql
   ```
3. Review the output to identify any corrupted indexes.

### Fixing Index Corruption

If corruption is detected, consider:

- **Reindexing the table:**
  ```sql
  REINDEX TABLE your_table_name;
  ```
- **Dropping and recreating the index:**
  ```sql
  DROP INDEX index_name;
  CREATE INDEX index_name ON table_name (column_name);
  ```

## Automating Index Checks

- Use **scheduled jobs** to run `IndexIntegrity.sql` periodically.
- Refer to **Job\_scheduled.png** and **Preview\_jobschedule.png** for guidance on setting up automation.


