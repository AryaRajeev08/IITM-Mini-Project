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
    password TEXT NOT NULL, 
    email TEXT
);


CREATE TRIGGER password_policy_trigger
BEFORE INSERT OR UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION enforce_password_policy();

--Add a Password Expiry Column

ALTER TABLE users ADD COLUMN password_expiry DATE DEFAULT NOW() + INTERVAL '90 days';

--Create the password_history Table
CREATE TABLE password_history (
    user_id INT REFERENCES users(id) ON DELETE CASCADE,
    hashed_password TEXT NOT NULL,
    changed_at TIMESTAMP DEFAULT now()
);

--Create the check_password_expiry() Function
CREATE OR REPLACE FUNCTION check_password_expiry()
RETURNS TRIGGER AS $$
DECLARE
    old_password TEXT;
    hashed_new_password TEXT;
BEGIN
    -- Check if the password is expired
    IF OLD.password_last_changed + INTERVAL '90 days' < now() THEN
        RAISE EXCEPTION 'Your password has expired. Please set a new one.';
    END IF;

    -- Hash the new password
    SELECT crypt(NEW.password, gen_salt('bf')) INTO hashed_new_password;

    -- Check the last 3 passwords
    IF EXISTS (
        SELECT 1 FROM password_history
        WHERE user_id = NEW.id
        ORDER BY changed_at DESC
        LIMIT 3
        AND hashed_password = hashed_new_password
    ) THEN
        RAISE EXCEPTION 'New password cannot be the same as the last 3 passwords.';
    END IF;

    -- Store the new password hash in history
    INSERT INTO password_history (user_id, hashed_password)
    VALUES (NEW.id, hashed_new_password);

    -- Update password change timestamp
    NEW.password_last_changed = now();

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


--Trigger for Password Changes
CREATE TRIGGER password_expiry_trigger
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION check_password_expiry();

--Automate Password Expiry Using pg_cron
CREATE EXTENSION IF NOT EXISTS pg_cron;

--Function to Expire Passwords Automatically
CREATE OR REPLACE FUNCTION expire_old_passwords() RETURNS VOID AS $$
BEGIN
    UPDATE users
    SET account_locked = TRUE
    WHERE password_last_changed + INTERVAL '90 days' < now()
    AND account_locked = FALSE;
END;
$$ LANGUAGE plpgsql;

--Schedule Automatic Expiry Check (Runs Daily at Midnight)
SELECT cron.schedule('0 0 * * *', 'CALL expire_old_passwords();');

--Send Warnings Before Expiry
SELECT email FROM users
WHERE password_expiry - INTERVAL '5 days' < now();
--we can use this email to send remainders.


INSERT INTO users (username, password) VALUES ('testuser', 'weakpass');

INSERT INTO users (username, password) VALUES ('testuser','StrongPass123!');







