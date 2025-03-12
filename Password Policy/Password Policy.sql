--sudo -i -u postgres
--psql


CREATE DATABASE test;
CREATE USER ad_user WITH ENCRYPTED PASSWORD '123';
GRANT ALL PRIVILEGES ON DATABASE test TO test;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE OR REPLACE FUNCTION enforce_password_policy()
RETURNS TRIGGER AS $$
BEGIN
    IF LENGTH(NEW.password) < 12 THEN
        RAISE EXCEPTION 'Password must be at least 12 characters long';
    END IF;
    IF NEW.password !~ '[A-Z]' THEN
        RAISE EXCEPTION 'Password must contain at least one uppercase letter';
    END IF;
    IF NEW.password !~ '[a-z]' THEN
        RAISE EXCEPTION 'Password must contain at least one lowercase letter';
    END IF;
    IF NEW.password !~ '[0-9]' THEN
        RAISE EXCEPTION 'Password must contain at least one number';
    END IF;
    IF NEW.password !~ '[!@#$%^&*()]' THEN
        RAISE EXCEPTION 'Password must contain at least one special character';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password TEXT NOT NULL
);


CREATE TRIGGER password_policy_trigger
BEFORE INSERT OR UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION enforce_password_policy();

--Add a Password Expiry Column

ALTER TABLE users ADD COLUMN password_expiry DATE DEFAULT NOW() + INTERVAL '90 days';

--Create a Trigger to Check Expiry

CREATE OR REPLACE FUNCTION check_password_expiry()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.password_expiry <= NOW() THEN
        RAISE EXCEPTION 'Password has expired. Please reset your password.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--Apply Expiry Trigger
CREATE TRIGGER password_expiry_trigger
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION check_password_expiry();


INSERT INTO users (username, password) VALUES ('testuser', 'weakpass');

INSERT INTO users (username, password) VALUES ('testuser','StrongPass123!');

