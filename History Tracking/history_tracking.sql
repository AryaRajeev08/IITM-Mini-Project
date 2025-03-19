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


