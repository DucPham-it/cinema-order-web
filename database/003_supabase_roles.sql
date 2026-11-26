-- Supabase SQL Editor only. Run as the schema owner after the schema files.
-- The roles stay NOLOGIN until you set a distinct password for each role.
BEGIN;
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'cinema_core_app') THEN
    CREATE ROLE cinema_core_app NOLOGIN NOINHERIT;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'cinema_payment_app') THEN
    CREATE ROLE cinema_payment_app NOLOGIN NOINHERIT;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'cinema_notification_app') THEN
    CREATE ROLE cinema_notification_app NOLOGIN NOINHERIT;
  END IF;
END $$;

REVOKE ALL ON SCHEMA cinema_core, cinema_payment, cinema_notification FROM PUBLIC;
GRANT USAGE ON SCHEMA cinema_core TO cinema_core_app;
GRANT USAGE ON SCHEMA cinema_payment TO cinema_payment_app;
GRANT USAGE ON SCHEMA cinema_notification TO cinema_notification_app;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA cinema_core TO cinema_core_app;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA cinema_payment TO cinema_payment_app;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA cinema_notification TO cinema_notification_app;

ALTER DEFAULT PRIVILEGES IN SCHEMA cinema_core
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO cinema_core_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA cinema_payment
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO cinema_payment_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA cinema_notification
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO cinema_notification_app;
COMMIT;
