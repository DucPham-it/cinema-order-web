-- Run after 001_init_schema.sql on local or Supabase.
BEGIN;
ALTER TABLE cinema_notification.notification_jobs
  ADD COLUMN IF NOT EXISTS created_at timestamptz NOT NULL DEFAULT now(),
  ADD COLUMN IF NOT EXISTS provider_message_id text;
COMMIT;
