--Step 1: Create Database

CREATE DATABASE index_checker;

--Step 2: Create required extensions

CREATE EXTENSION amcheck;
CREATE EXTENSION pg_cron;

--Step 3: Create a corruption log table
 
CREATE TABLE corruption_logs (
    id SERIAL PRIMARY KEY,
    index_name TEXT NOT NULL,
    table_name TEXT NOT NULL,
    detected_at TIMESTAMP DEFAULT now()
);


--Step 4: Create a function to check and fix the indexes

CREATE OR REPLACE FUNCTION check_index_integrity()
RETURNS void AS $$
DECLARE
    rec RECORD;
    corruption_found BOOLEAN := FALSE;
BEGIN
    FOR rec IN 
        SELECT indexrelid::regclass AS index_name, indrelid::regclass AS table_name
        FROM pg_index
    LOOP
        BEGIN
            -- Check index integrity
            PERFORM bt_index_check(rec.index_name);
        EXCEPTION
            WHEN OTHERS THEN
                corruption_found := TRUE;
                RAISE NOTICE 'Corruption found in index: %, Table: %', rec.index_name, rec.table_name;

                -- Log corruption
                INSERT INTO corruption_logs (index_name, table_name, detected_at)
$$ LANGUAGE plpgsql; 'No index corruption found.'; rec.index_name);


--Step 5: View the corrupted indexes if any

SELECT * FROM corruption_logs ORDER BY detected_at DESC;


--Step 6: Schedule Automatic check

SELECT cron.schedule(
    'index_check_job',
    '0 0 * * *', -- Runs daily at midnight
    $$CALL check_index_integrity()$$
);


--Step 7: View the scheduled job
SELECT * FROM cron.job;


