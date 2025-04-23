-- Step 1: Enable pg_cron extension
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Step 2: Create corruption log table (if not exists)
CREATE TABLE IF NOT EXISTS corruption_log (
    id SERIAL PRIMARY KEY,
    table_name TEXT NOT NULL,
    index_name TEXT NOT NULL,
    issue_description TEXT NOT NULL,
    detected_at TIMESTAMP DEFAULT NOW(),
    status TEXT NOT NULL
);

-- Step 3: Function to check and reindex a given table
CREATE OR REPLACE FUNCTION check_and_reindex(input_table_name TEXT) RETURNS VOID AS $$
DECLARE
    index_record RECORD;
BEGIN
    -- Check for corrupt indexes using amcheck
    FOR index_record IN
        SELECT indexrelid::regclass::text AS index_name
        FROM pg_index
        WHERE indrelid = input_table_name::regclass
    LOOP
        BEGIN
            EXECUTE format('SELECT bt_index_check(%I)', index_record.index_name);
        EXCEPTION
            WHEN OTHERS THEN
                -- Log corruption
                INSERT INTO corruption_log (table_name, index_name, issue_description, status)
                VALUES (input_table_name, index_record.index_name, 'Corruption detected during amcheck', 'Pending');

                -- Attempt REINDEX CONCURRENTLY
                BEGIN
                    EXECUTE format('REINDEX INDEX CONCURRENTLY %I', index_record.index_name);
                    UPDATE corruption_log
                    SET status = 'Reindexed'
                    WHERE table_name = input_table_name
                      AND index_name = index_record.index_name
                      AND status = 'Pending';
                EXCEPTION
                    WHEN OTHERS THEN
                        -- Attempt regular REINDEX if concurrent fails
                        BEGIN
                            EXECUTE format('REINDEX INDEX %I', index_record.index_name);
                            UPDATE corruption_log
                            SET status = 'Reindexed'
                            WHERE table_name = input_table_name
                              AND index_name = index_record.index_name
                              AND status = 'Pending';
                        EXCEPTION
                            WHEN OTHERS THEN
                                -- Final fallback: mark reindex as failed
                                UPDATE corruption_log
                                SET status = 'Reindex Failed'
                                WHERE table_name = input_table_name
                                  AND index_name = index_record.index_name
                                  AND status = 'Pending';
                        END;
                END;
        END;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Step 4: Wrapper function to check and reindex all tables in the public schema
CREATE OR REPLACE FUNCTION check_and_reindex_all_tables() RETURNS VOID AS $$
DECLARE
    tbl RECORD;
BEGIN
    FOR tbl IN
        SELECT tablename
        FROM pg_tables
        WHERE schemaname = 'public'
    LOOP
        PERFORM check_and_reindex(tbl.tablename);
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Step 5: Schedule the cron job to run daily at midnight
SELECT cron.schedule(
    'reindex_all_tables_daily',
    '0 0 * * *',
    $$ SELECT check_and_reindex_all_tables(); $$
);

-- Step 6: View the scheduled job
SELECT * FROM cron.job;

