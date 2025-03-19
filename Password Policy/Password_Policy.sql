-- Create Database and User
CREATE DATABASE test;
CREATE USER ad_user WITH ENCRYPTED PASSWORD '123';
GRANT ALL PRIVILEGES ON DATABASE test TO ad_user;

-- Enable pgcrypto for password hashing (keeping this in case needed)
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Create Users Table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password TEXT NOT NULL, 
    email TEXT,
    password_expiry DATE DEFAULT (NOW() + INTERVAL '90 days'),
    account_locked BOOLEAN DEFAULT FALSE
);

-- Password Policy Function
CREATE OR REPLACE FUNCTION enforce_password_policy()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.password IS DISTINCT FROM OLD.password THEN
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
        RAISE NOTICE 'Password meets all security requirements.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER password_policy_trigger
BEFORE INSERT OR UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION enforce_password_policy();

-- Create Password History Table
CREATE TABLE password_history (
    user_id INT REFERENCES users(id) ON DELETE CASCADE,
    old_password TEXT NOT NULL,
    changed_at TIMESTAMP DEFAULT now()
);

-- Enforce Password Expiry and History
CREATE OR REPLACE FUNCTION check_password_expiry()
RETURNS TRIGGER AS $$
BEGIN
    -- Only check if the password is being changed
    IF NEW.password IS DISTINCT FROM OLD.password THEN
        -- Check if the password is expired
        IF OLD.password_expiry < now() THEN
            RAISE EXCEPTION 'Your password has expired. Please set a new one.';
        END IF;
        
        -- Prevent reuse of last 3 passwords
        IF EXISTS (
            SELECT 1 FROM (
                SELECT old_password FROM password_history
                WHERE user_id = NEW.id
                ORDER BY changed_at DESC
                LIMIT 3
            ) AS last_three_passwords
            WHERE old_password = NEW.password
        ) THEN
            RAISE EXCEPTION 'New password cannot be the same as the last 3 passwords.';
        END IF;
        
        -- Store the old password in history
        INSERT INTO password_history (user_id, old_password)
        VALUES (NEW.id, OLD.password);
        
        -- Update password expiry
        NEW.password_expiry = now() + INTERVAL '90 days';
        RAISE NOTICE 'Password successfully changed and stored in history.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER password_expiry_trigger
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION check_password_expiry();

-- Automate Password Expiry
CREATE EXTENSION IF NOT EXISTS pg_cron;

CREATE OR REPLACE FUNCTION expire_old_passwords() RETURNS VOID AS $$
BEGIN
    UPDATE users
    SET account_locked = TRUE
    WHERE password_expiry < now()
    AND account_locked = FALSE;
    RAISE NOTICE 'Expired passwords detected and accounts locked where necessary.';
END;
$$ LANGUAGE plpgsql;

SELECT cron.schedule('0 0 * * *', 'SELECT expire_old_passwords();');

-- Get Users Close to Password Expiry
SELECT email FROM users WHERE password_expiry - INTERVAL '5 days' < now();

