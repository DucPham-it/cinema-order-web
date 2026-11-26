-- PostgreSQL 17. For an empty app schema. Run each matching block on Supabase.
-- Run the entire file on the local PostgreSQL container.

-- CORE BEGIN. Run this block on the Core database.
BEGIN;
CREATE SCHEMA IF NOT EXISTS extensions;
CREATE EXTENSION IF NOT EXISTS btree_gist WITH SCHEMA extensions;
CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;
CREATE SCHEMA IF NOT EXISTS cinema_core;
REVOKE ALL ON SCHEMA cinema_core FROM PUBLIC;
SET LOCAL search_path = cinema_core, extensions, public, pg_catalog;

CREATE TABLE cinemas (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  address text NOT NULL,
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active','inactive'))
);
CREATE TABLE auditoriums (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  cinema_id uuid NOT NULL REFERENCES cinemas,
  name text NOT NULL,
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active','inactive')),
  UNIQUE (cinema_id,name)
);
CREATE TABLE seats (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  auditorium_id uuid NOT NULL REFERENCES auditoriums,
  row_label text NOT NULL,
  seat_number integer NOT NULL CHECK (seat_number > 0),
  kind text NOT NULL CHECK (kind IN ('standard','vip','couple')),
  x integer NOT NULL,
  y integer NOT NULL,
  is_active boolean NOT NULL DEFAULT true,
  UNIQUE (auditorium_id,row_label,seat_number),
  UNIQUE (id,auditorium_id)
);
CREATE TABLE users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text NOT NULL UNIQUE CHECK (email = lower(btrim(email))),
  password_hash text NOT NULL,
  full_name text NOT NULL,
  phone text,
  role text NOT NULL DEFAULT 'customer' CHECK (role IN ('admin','customer','staff','manager')),
  cinema_id uuid REFERENCES cinemas,
  email_verified_at timestamptz,
  disabled_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  CHECK ((role IN ('staff','manager')) = (cinema_id IS NOT NULL))
);
CREATE TABLE refresh_sessions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users,
  family_id uuid NOT NULL,
  token_hash text NOT NULL UNIQUE,
  expires_at timestamptz NOT NULL,
  used_at timestamptz,
  revoked_at timestamptz
);
CREATE INDEX refresh_sessions_family ON refresh_sessions (user_id,family_id);
CREATE TABLE email_tokens (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users,
  purpose text NOT NULL CHECK (purpose IN ('verify_email','reset_password')),
  token_hash text NOT NULL UNIQUE,
  expires_at timestamptz NOT NULL,
  used_at timestamptz
);
CREATE TABLE movies (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  slug text NOT NULL UNIQUE,
  synopsis text NOT NULL,
  poster_url text,
  trailer_url text CHECK (trailer_url ~ '^https://www[.]youtube[.]com/watch[?]v=[A-Za-z0-9_-]{11}$'),
  duration_minutes integer NOT NULL CHECK (duration_minutes > 0),
  age_rating text NOT NULL,
  release_date date NOT NULL,
  status text NOT NULL CHECK (status IN ('coming_soon','now_showing','archived'))
);
CREATE TABLE genres (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE
);
CREATE TABLE movie_genres (
  movie_id uuid REFERENCES movies,
  genre_id uuid REFERENCES genres,
  PRIMARY KEY (movie_id,genre_id)
);
CREATE TABLE showtimes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  movie_id uuid NOT NULL REFERENCES movies,
  auditorium_id uuid NOT NULL REFERENCES auditoriums,
  format text NOT NULL CHECK (format IN ('2D','3D','IMAX')),
  starts_at timestamptz NOT NULL,
  ends_at timestamptz NOT NULL,
  status text NOT NULL DEFAULT 'draft' CHECK (status IN ('draft','on_sale','started','completed','cancelled')),
  CHECK (ends_at > starts_at),
  UNIQUE (id,auditorium_id),
  EXCLUDE USING gist (
    auditorium_id WITH =,
    tstzrange(starts_at,ends_at,'[)') WITH &&
  ) WHERE (status <> 'cancelled')
);
CREATE INDEX showtimes_movie_starts ON showtimes (movie_id,starts_at);
CREATE INDEX showtimes_room_starts ON showtimes (auditorium_id,starts_at);
CREATE TABLE price_rules (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  cinema_id uuid NOT NULL REFERENCES cinemas,
  format text NOT NULL CHECK (format IN ('2D','3D','IMAX')),
  seat_kind text NOT NULL CHECK (seat_kind IN ('standard','vip','couple')),
  amount_vnd bigint NOT NULL CHECK (amount_vnd >= 0),
  active boolean NOT NULL DEFAULT true
);
CREATE UNIQUE INDEX price_rules_one_active ON price_rules (cinema_id,format,seat_kind) WHERE active;
CREATE TABLE combos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  cinema_id uuid NOT NULL REFERENCES cinemas,
  name text NOT NULL,
  price_vnd bigint NOT NULL CHECK (price_vnd >= 0),
  active boolean NOT NULL DEFAULT true,
  UNIQUE (cinema_id,name)
);
CREATE TABLE seat_holds (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  showtime_id uuid NOT NULL REFERENCES showtimes,
  customer_id uuid REFERENCES users,
  guest_secret_hash text,
  expires_at timestamptz NOT NULL,
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active','released','expired','converted')),
  CHECK ((customer_id IS NULL) <> (guest_secret_hash IS NULL)),
  UNIQUE (id,showtime_id)
);
CREATE TABLE bookings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  showtime_id uuid NOT NULL REFERENCES showtimes,
  hold_id uuid NOT NULL UNIQUE,
  user_id uuid REFERENCES users,
  booking_code_hash text NOT NULL UNIQUE,
  contact_name text NOT NULL,
  contact_email text NOT NULL,
  contact_phone text,
  status text NOT NULL DEFAULT 'pending_payment'
    CHECK (status IN ('pending_payment','confirmed','expired','cancellation_pending','cancelled')),
  total_vnd bigint NOT NULL CHECK (total_vnd >= 0),
  expires_at timestamptz NOT NULL,
  confirmed_at timestamptz,
  cancelled_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  FOREIGN KEY (hold_id,showtime_id) REFERENCES seat_holds (id,showtime_id),
  UNIQUE (id,showtime_id)
);
CREATE INDEX bookings_user_created ON bookings (user_id,created_at DESC);
CREATE INDEX bookings_showtime_status ON bookings (showtime_id,status);
CREATE TABLE showtime_seats (
  showtime_id uuid,
  seat_id uuid,
  auditorium_id uuid NOT NULL,
  status text NOT NULL DEFAULT 'available' CHECK (status IN ('available','held','sold')),
  hold_id uuid,
  hold_expires_at timestamptz,
  booking_id uuid,
  PRIMARY KEY (showtime_id,seat_id),
  FOREIGN KEY (showtime_id,auditorium_id) REFERENCES showtimes (id,auditorium_id),
  FOREIGN KEY (seat_id,auditorium_id) REFERENCES seats (id,auditorium_id),
  FOREIGN KEY (hold_id,showtime_id) REFERENCES seat_holds (id,showtime_id),
  FOREIGN KEY (booking_id,showtime_id) REFERENCES bookings (id,showtime_id),
  CHECK (
    (status = 'available' AND hold_id IS NULL AND hold_expires_at IS NULL AND booking_id IS NULL)
    OR (status = 'held' AND hold_id IS NOT NULL AND hold_expires_at IS NOT NULL)
    OR (status = 'sold' AND hold_id IS NULL AND hold_expires_at IS NULL AND booking_id IS NOT NULL)
  )
);
CREATE INDEX showtime_seats_hold_expiry ON showtime_seats (hold_expires_at) WHERE status = 'held';
CREATE TABLE booking_seats (
  booking_id uuid,
  showtime_id uuid NOT NULL,
  seat_id uuid,
  seat_label text NOT NULL,
  seat_kind text NOT NULL CHECK (seat_kind IN ('standard','vip','couple')),
  price_vnd bigint NOT NULL CHECK (price_vnd >= 0),
  PRIMARY KEY (booking_id,seat_id),
  FOREIGN KEY (booking_id,showtime_id) REFERENCES bookings (id,showtime_id),
  FOREIGN KEY (showtime_id,seat_id) REFERENCES showtime_seats (showtime_id,seat_id)
);
CREATE TABLE booking_combos (
  booking_id uuid REFERENCES bookings,
  combo_id uuid REFERENCES combos,
  name text NOT NULL,
  unit_price_vnd bigint NOT NULL CHECK (unit_price_vnd >= 0),
  quantity integer NOT NULL CHECK (quantity > 0),
  PRIMARY KEY (booking_id,combo_id)
);
CREATE TABLE payment_attempts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id uuid NOT NULL REFERENCES bookings,
  external_payment_id uuid UNIQUE,
  amount_vnd bigint NOT NULL CHECK (amount_vnd >= 0),
  status text NOT NULL CHECK (status IN ('pending','succeeded','failed','refunded')),
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX payment_attempts_booking ON payment_attempts (booking_id);
CREATE TABLE processed_payment_events (
  event_id uuid PRIMARY KEY,
  payment_attempt_id uuid NOT NULL REFERENCES payment_attempts,
  kind text NOT NULL CHECK (kind IN ('payment.succeeded','payment.failed','refund.succeeded','refund.failed')),
  payload jsonb NOT NULL,
  processed_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE outbox_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  kind text NOT NULL,
  payload jsonb NOT NULL,
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','processing','sent','failed')),
  attempts integer NOT NULL DEFAULT 0 CHECK (attempts >= 0),
  next_attempt_at timestamptz NOT NULL DEFAULT now(),
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX outbox_events_ready ON outbox_events (next_attempt_at) WHERE status = 'pending';
CREATE TABLE tickets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id uuid NOT NULL,
  seat_id uuid NOT NULL,
  qr_token_hash text NOT NULL UNIQUE,
  status text NOT NULL DEFAULT 'valid' CHECK (status IN ('valid','checked_in','void')),
  UNIQUE (booking_id,seat_id),
  FOREIGN KEY (booking_id,seat_id) REFERENCES booking_seats (booking_id,seat_id)
);
CREATE TABLE ticket_check_ins (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  ticket_id uuid NOT NULL UNIQUE REFERENCES tickets,
  staff_id uuid NOT NULL REFERENCES users,
  checked_in_at timestamptz NOT NULL DEFAULT now()
);
COMMIT;
-- CORE END

-- PAYMENT BEGIN. Run this block on the Payment database.
BEGIN;
CREATE SCHEMA IF NOT EXISTS cinema_payment;
REVOKE ALL ON SCHEMA cinema_payment FROM PUBLIC;
SET LOCAL search_path = cinema_payment, pg_catalog;
CREATE TABLE payments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_ref uuid NOT NULL,
  amount_vnd bigint NOT NULL CHECK (amount_vnd >= 0),
  currency text NOT NULL DEFAULT 'VND' CHECK (currency = 'VND'),
  status text NOT NULL CHECK (status IN ('pending','succeeded','failed','refunded')),
  idempotency_key text NOT NULL UNIQUE,
  expires_at timestamptz NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX payments_booking ON payments (booking_ref);
CREATE TABLE refunds (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  payment_id uuid NOT NULL REFERENCES payments,
  amount_vnd bigint NOT NULL CHECK (amount_vnd > 0),
  reason text NOT NULL,
  status text NOT NULL CHECK (status IN ('pending','succeeded','failed')),
  idempotency_key text NOT NULL UNIQUE,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX refunds_payment ON refunds (payment_id);
CREATE TABLE webhook_deliveries (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id uuid NOT NULL UNIQUE,
  payment_id uuid NOT NULL REFERENCES payments,
  body jsonb NOT NULL,
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','processing','sent','failed')),
  attempts integer NOT NULL DEFAULT 0 CHECK (attempts >= 0),
  next_attempt_at timestamptz NOT NULL DEFAULT now(),
  delivered_at timestamptz
);
CREATE INDEX webhook_deliveries_ready ON webhook_deliveries (next_attempt_at) WHERE status = 'pending';
COMMIT;
-- PAYMENT END

-- NOTIFICATION BEGIN. Run this block on the Notification database.
BEGIN;
CREATE SCHEMA IF NOT EXISTS cinema_notification;
REVOKE ALL ON SCHEMA cinema_notification FROM PUBLIC;
SET LOCAL search_path = cinema_notification, pg_catalog;
CREATE TABLE notification_jobs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  idempotency_key text NOT NULL UNIQUE,
  template text NOT NULL CHECK (template IN ('verify_email','reset_password','ticket_issued')),
  recipient text NOT NULL,
  data jsonb NOT NULL,
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','processing','sent','failed')),
  attempts integer NOT NULL DEFAULT 0 CHECK (attempts >= 0),
  next_attempt_at timestamptz NOT NULL DEFAULT now(),
  sent_at timestamptz
);
CREATE INDEX notification_jobs_ready ON notification_jobs (next_attempt_at) WHERE status = 'pending';
COMMIT;
-- NOTIFICATION END
