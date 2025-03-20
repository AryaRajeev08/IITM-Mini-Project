-- create database and user for prometheus
CREATE DATABASE testdb;
CREATE USER prometheus WITH ENCRYPTED PASSWORD 'password';

-- Execute Privilege on pg_ls_waldir function
GRANT EXECUTE ON FUNCTION pg_ls_waldir() TO prometheus;



-- create user for postgresql_explorer
CREATE USER exporter WITH PASSWORD 'exporterpassword';
ALTER USER exporter WITH SUPERUSER;


-- create audit table
CREATE TABLE audit_log (
    audit_id SERIAL PRIMARY KEY,
    table_name TEXT,
    operation TEXT,
    old_data JSONB,
    new_data JSONB,
    changed_by TEXT,
    changed_at TIMESTAMP DEFAULT NOW()
);


-- create a trigger function
CREATE OR REPLACE FUNCTION log_changes()
RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'UPDATE') THEN
    INSERT INTO audit_log (table_name, operation, old_data, new_data, changed_by)
    VALUES (TG_TABLE_NAME, TG_OP, row_to_json(OLD), row_to_json(NEW), current_user);
  ELSIF (TG_OP = 'DELETE') THEN
    INSERT INTO audit_log (table_name, operation, old_data, changed_by)
    VALUES (TG_TABLE_NAME, TG_OP, row_to_json(OLD), current_user);
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO audit_log (table_name, operation, new_data, changed_by)
    VALUES (TG_TABLE_NAME, TG_OP, row_to_json(NEW), current_user);
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;


--apply trigger to a table
CREATE TRIGGER track_changes
AFTER INSERT OR UPDATE OR DELETE ON my_table
FOR EACH ROW EXECUTE FUNCTION log_changes();


-- INDEX BLOAT

-- Install pgstattuple
CREATE EXTENSION IF NOT EXISTS pgstattuple;

-- Verify installation
SELECT * FROM pg_extension WHERE extname = 'pgstattuple';


-- Detect Index Bloat
SELECT
  stat.indexrelid::regclass AS index_name,
  pg_size_pretty(pg_relation_size(stat.indexrelid)) AS index_size,
  pg_stat_get_blocks_fetched(stat.indexrelid) AS blocks_fetched,
  stat.idx_scan AS index_scans,
  CASE
    WHEN stat.idx_scan = 0 THEN NULL
    ELSE 100 * (1 - pg_stat_get_blocks_fetched(stat.indexrelid)::float / stat.idx_scan)
  END AS cache_hit_ratio,
  pg_stat_get_numscans(stat.indexrelid) AS num_scans
FROM
  pg_stat_user_indexes AS stat
JOIN
  pg_index AS idx ON idx.indexrelid = stat.indexrelid
WHERE
  pg_stat_get_blocks_fetched(stat.indexrelid) > 0;


-- Additional Index Bloat Check
SELECT
  stat.indexrelid::regclass AS index_name,
  cls.relname AS table_name,
  nsp.nspname AS schema_name,
  pg_size_pretty(pg_relation_size(stat.indexrelid)) AS index_size,
  stat.idx_scan AS index_scans,
  stat.idx_tup_read AS tuples_read,
  stat.idx_tup_fetch AS tuples_fetched
FROM
  pg_stat_user_indexes AS stat
JOIN
  pg_class AS cls ON cls.oid = stat.relid
JOIN
  pg_namespace AS nsp ON nsp.oid = cls.relnamespace
ORDER BY
  pg_relation_size(stat.indexrelid) DESC;


-- Remove bloat by recreating indexes
    --Find the index names
SELECT indexrelid::regclass AS index_name
FROM pg_stat_user_indexes;                 

    -- Remove bloat
REINDEX INDEX index_name;  -- replace index_name with the your index names


-- Clean up dead tuples.
VACUUM ANALYZE;


-- Index bloat in grafana
WITH index_info AS (
  SELECT
    psui.schemaname,
    psui.relname AS tablename,
    psui.indexrelname AS indexname,
    pg_relation_size(psui.indexrelid) AS index_size,
    psui.idx_scan AS index_scans,
    pg_size_pretty(pg_relation_size(psui.indexrelid)) AS index_size_pretty
  FROM
    pg_stat_user_indexes psui
  JOIN
    pg_indexes pi ON psui.indexrelname = pi.indexname
)
SELECT
  schemaname,
  tablename,
  indexname,
  index_size,
  index_scans,
  index_size_pretty
FROM
  index_info
ORDER BY
  index_size DESC;