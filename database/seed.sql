-- Demo databases only. Demo accounts have a public password.
-- Run only the matching block per Supabase project; Docker runs all three.
-- Fixed fixture IDs make reruns non-destructive. Schedule dates are relative to first load.

-- CORE BEGIN
BEGIN;
SET LOCAL search_path = cinema_core, extensions, public, pg_catalog;

INSERT INTO cinemas (id, name, address) VALUES
  (md5('cinema-demo:cinema:1')::uuid, 'Cinema Demo 1', 'Địa chỉ mẫu 1, TP HCM'),
  (md5('cinema-demo:cinema:2')::uuid, 'Cinema Demo 2', 'Địa chỉ mẫu 2, TP HCM'),
  (md5('cinema-demo:cinema:3')::uuid, 'Cinema Demo 3', 'Địa chỉ mẫu 3, TP HCM'),
  (md5('cinema-demo:cinema:4')::uuid, 'Cinema Demo 4', 'Địa chỉ mẫu 4, TP HCM'),
  (md5('cinema-demo:cinema:5')::uuid, 'Cinema Demo 5', 'Địa chỉ mẫu 5, TP HCM')
ON CONFLICT DO NOTHING;

INSERT INTO auditoriums (id, cinema_id, name) VALUES
  (md5('cinema-demo:room:1')::uuid, md5('cinema-demo:cinema:1')::uuid, 'Phòng 1'),
  (md5('cinema-demo:room:2')::uuid, md5('cinema-demo:cinema:2')::uuid, 'Phòng 1'),
  (md5('cinema-demo:room:3')::uuid, md5('cinema-demo:cinema:3')::uuid, 'Phòng 1'),
  (md5('cinema-demo:room:4')::uuid, md5('cinema-demo:cinema:4')::uuid, 'Phòng 1'),
  (md5('cinema-demo:room:5')::uuid, md5('cinema-demo:cinema:5')::uuid, 'Phòng 1')
ON CONFLICT DO NOTHING;

INSERT INTO seats (id, auditorium_id, row_label, seat_number, kind, x, y) VALUES
  (md5('cinema-demo:seat:1')::uuid, md5('cinema-demo:room:1')::uuid, 'A', 1, 'standard', 1, 1),
  (md5('cinema-demo:seat:2')::uuid, md5('cinema-demo:room:1')::uuid, 'A', 2, 'standard', 2, 1),
  (md5('cinema-demo:seat:3')::uuid, md5('cinema-demo:room:1')::uuid, 'A', 3, 'vip', 3, 1),
  (md5('cinema-demo:seat:4')::uuid, md5('cinema-demo:room:1')::uuid, 'A', 4, 'vip', 4, 1),
  (md5('cinema-demo:seat:5')::uuid, md5('cinema-demo:room:1')::uuid, 'A', 5, 'couple', 5, 1)
ON CONFLICT DO NOTHING;

INSERT INTO users (id, email, password_hash, full_name, role, cinema_id, email_verified_at) VALUES
  (md5('cinema-demo:user:1')::uuid, 'admin@cinema.example', crypt('CinemaDemo2026!', gen_salt('bf', 12)), 'Tài khoản admin', 'admin', NULL, now()),
  (md5('cinema-demo:user:2')::uuid, 'user@cinema.example', crypt('CinemaDemo2026!', gen_salt('bf', 12)), 'Tài khoản user', 'customer', NULL, now()),
  (md5('cinema-demo:user:3')::uuid, 'staff@cinema.example', crypt('CinemaDemo2026!', gen_salt('bf', 12)), 'Tài khoản staff', 'staff', md5('cinema-demo:cinema:1')::uuid, now()),
  (md5('cinema-demo:user:4')::uuid, 'manager@cinema.example', crypt('CinemaDemo2026!', gen_salt('bf', 12)), 'Tài khoản manager', 'manager', md5('cinema-demo:cinema:1')::uuid, now()),
  (md5('cinema-demo:user:5')::uuid, 'customer02@cinema.example', crypt('CinemaDemo2026!', gen_salt('bf', 12)), 'Tài khoản customer02', 'customer', NULL, NULL)
ON CONFLICT DO NOTHING;

INSERT INTO refresh_sessions (id, user_id, family_id, token_hash, expires_at, revoked_at) VALUES
  (md5('cinema-demo:refresh:1')::uuid, md5('cinema-demo:user:1')::uuid, md5('cinema-demo:family:1')::uuid, encode(digest('revoked-demo-refresh-1','sha256'),'hex'), now() - interval '1 day', now() - interval '2 days'),
  (md5('cinema-demo:refresh:2')::uuid, md5('cinema-demo:user:2')::uuid, md5('cinema-demo:family:2')::uuid, encode(digest('revoked-demo-refresh-2','sha256'),'hex'), now() - interval '1 day', now() - interval '2 days'),
  (md5('cinema-demo:refresh:3')::uuid, md5('cinema-demo:user:3')::uuid, md5('cinema-demo:family:3')::uuid, encode(digest('revoked-demo-refresh-3','sha256'),'hex'), now() - interval '1 day', now() - interval '2 days'),
  (md5('cinema-demo:refresh:4')::uuid, md5('cinema-demo:user:4')::uuid, md5('cinema-demo:family:4')::uuid, encode(digest('revoked-demo-refresh-4','sha256'),'hex'), now() - interval '1 day', now() - interval '2 days'),
  (md5('cinema-demo:refresh:5')::uuid, md5('cinema-demo:user:5')::uuid, md5('cinema-demo:family:5')::uuid, encode(digest('revoked-demo-refresh-5','sha256'),'hex'), now() - interval '1 day', now() - interval '2 days')
ON CONFLICT DO NOTHING;

INSERT INTO email_tokens (id, user_id, purpose, token_hash, expires_at, used_at) VALUES
  (md5('cinema-demo:emailtoken:1')::uuid, md5('cinema-demo:user:1')::uuid, 'reset_password', encode(digest('used-demo-email-1','sha256'),'hex'), now() - interval '1 day', now() - interval '2 days'),
  (md5('cinema-demo:emailtoken:2')::uuid, md5('cinema-demo:user:2')::uuid, 'reset_password', encode(digest('used-demo-email-2','sha256'),'hex'), now() - interval '1 day', now() - interval '2 days'),
  (md5('cinema-demo:emailtoken:3')::uuid, md5('cinema-demo:user:3')::uuid, 'reset_password', encode(digest('used-demo-email-3','sha256'),'hex'), now() - interval '1 day', now() - interval '2 days'),
  (md5('cinema-demo:emailtoken:4')::uuid, md5('cinema-demo:user:4')::uuid, 'reset_password', encode(digest('used-demo-email-4','sha256'),'hex'), now() - interval '1 day', now() - interval '2 days'),
  (md5('cinema-demo:emailtoken:5')::uuid, md5('cinema-demo:user:5')::uuid, 'verify_email', encode(digest('used-demo-email-5','sha256'),'hex'), now() - interval '1 day', now() - interval '2 days')
ON CONFLICT DO NOTHING;

INSERT INTO movies (id, title, slug, synopsis, poster_url, trailer_url, duration_minutes, age_rating, release_date, status) VALUES
  (md5('cinema-demo:movie:1')::uuid, 'Mặt Trời', 'phim-demo-1', 'Phim minh họa', NULL, 'https://www.youtube.com/watch?v=DEMO_VIDEO1', 100, 'P', current_date - 7, 'now_showing'),
  (md5('cinema-demo:movie:2')::uuid, 'Đêm Mưa', 'phim-demo-2', 'Phim minh họa', NULL, NULL, 100, 'P', current_date - 7, 'now_showing'),
  (md5('cinema-demo:movie:3')::uuid, 'Đường Về', 'phim-demo-3', 'Phim minh họa', NULL, NULL, 100, 'P', current_date - 7, 'now_showing'),
  (md5('cinema-demo:movie:4')::uuid, 'Phía Chân Trời', 'phim-demo-4', 'Phim minh họa', NULL, NULL, 100, 'P', current_date - 7, 'now_showing'),
  (md5('cinema-demo:movie:5')::uuid, 'Ký Ức Mùa Hạ', 'phim-demo-5', 'Phim minh họa', NULL, NULL, 100, 'T13', current_date - 7, 'now_showing')
ON CONFLICT DO NOTHING;

INSERT INTO genres (id, name) VALUES
  (md5('cinema-demo:genre:1')::uuid, 'Phiêu lưu'),
  (md5('cinema-demo:genre:2')::uuid, 'Hành động'),
  (md5('cinema-demo:genre:3')::uuid, 'Hài'),
  (md5('cinema-demo:genre:4')::uuid, 'Tâm lý'),
  (md5('cinema-demo:genre:5')::uuid, 'Gia đình')
ON CONFLICT DO NOTHING;

INSERT INTO movie_genres (movie_id, genre_id) VALUES
  (md5('cinema-demo:movie:1')::uuid, md5('cinema-demo:genre:1')::uuid),
  (md5('cinema-demo:movie:2')::uuid, md5('cinema-demo:genre:2')::uuid),
  (md5('cinema-demo:movie:3')::uuid, md5('cinema-demo:genre:3')::uuid),
  (md5('cinema-demo:movie:4')::uuid, md5('cinema-demo:genre:4')::uuid),
  (md5('cinema-demo:movie:5')::uuid, md5('cinema-demo:genre:5')::uuid)
ON CONFLICT DO NOTHING;

INSERT INTO showtimes (id, movie_id, auditorium_id, format, starts_at, ends_at, status) VALUES
  (md5('cinema-demo:show:1')::uuid, md5('cinema-demo:movie:1')::uuid, md5('cinema-demo:room:1')::uuid, '2D', now() - interval '15 minutes', now() + interval '85 minutes', 'started'),
  (md5('cinema-demo:show:2')::uuid, md5('cinema-demo:movie:2')::uuid, md5('cinema-demo:room:1')::uuid, '2D', now() + interval '2 days', now() + interval '2 days 100 minutes', 'on_sale'),
  (md5('cinema-demo:show:3')::uuid, md5('cinema-demo:movie:3')::uuid, md5('cinema-demo:room:3')::uuid, '2D', now() + interval '3 days', now() + interval '3 days 100 minutes', 'draft'),
  (md5('cinema-demo:show:4')::uuid, md5('cinema-demo:movie:4')::uuid, md5('cinema-demo:room:4')::uuid, '3D', now() + interval '4 days', now() + interval '4 days 100 minutes', 'draft'),
  (md5('cinema-demo:show:5')::uuid, md5('cinema-demo:movie:5')::uuid, md5('cinema-demo:room:5')::uuid, 'IMAX', now() + interval '5 days', now() + interval '5 days 100 minutes', 'draft')
ON CONFLICT DO NOTHING;

INSERT INTO price_rules (id, cinema_id, format, seat_kind, amount_vnd) VALUES
  (md5('cinema-demo:price:1')::uuid, md5('cinema-demo:cinema:1')::uuid,  '2D', 'standard', 95000),
  (md5('cinema-demo:price:2')::uuid, md5('cinema-demo:cinema:1')::uuid,  '2D', 'vip', 130000),
  (md5('cinema-demo:price:3')::uuid, md5('cinema-demo:cinema:1')::uuid,  '2D', 'couple', 170000),
  (md5('cinema-demo:price:4')::uuid, md5('cinema-demo:cinema:4')::uuid,  '2D', 'standard', 90000),
  (md5('cinema-demo:price:5')::uuid, md5('cinema-demo:cinema:5')::uuid,  '2D', 'standard', 100000)
ON CONFLICT DO NOTHING;

INSERT INTO combos (id, cinema_id, name, price_vnd) VALUES
  (md5('cinema-demo:combo:1')::uuid, md5('cinema-demo:cinema:1')::uuid, 'Combo Bắp Nước 1', 65000),
  (md5('cinema-demo:combo:2')::uuid, md5('cinema-demo:cinema:1')::uuid, 'Combo Bắp Nước 2', 70000),
  (md5('cinema-demo:combo:3')::uuid, md5('cinema-demo:cinema:1')::uuid, 'Combo Bắp Nước 3', 75000),
  (md5('cinema-demo:combo:4')::uuid, md5('cinema-demo:cinema:1')::uuid, 'Combo Bắp Nước 4', 80000),
  (md5('cinema-demo:combo:5')::uuid, md5('cinema-demo:cinema:1')::uuid, 'Combo Bắp Nước 5', 85000)
ON CONFLICT DO NOTHING;

INSERT INTO seat_holds (id, showtime_id, customer_id, guest_secret_hash, expires_at, status) VALUES
  (md5('cinema-demo:hold:1')::uuid, md5('cinema-demo:show:1')::uuid, md5('cinema-demo:user:2')::uuid, NULL, now() - interval '23 hours 55 minutes', 'converted'),
  (md5('cinema-demo:hold:2')::uuid, md5('cinema-demo:show:1')::uuid, md5('cinema-demo:user:2')::uuid, NULL, now() - interval '23 hours 55 minutes', 'converted'),
  (md5('cinema-demo:hold:3')::uuid, md5('cinema-demo:show:1')::uuid, md5('cinema-demo:user:2')::uuid, NULL, now() - interval '23 hours 55 minutes', 'converted'),
  (md5('cinema-demo:hold:4')::uuid, md5('cinema-demo:show:1')::uuid, md5('cinema-demo:user:2')::uuid, NULL, now() - interval '23 hours 55 minutes', 'converted'),
  (md5('cinema-demo:hold:5')::uuid, md5('cinema-demo:show:1')::uuid, md5('cinema-demo:user:2')::uuid, NULL, now() - interval '23 hours 55 minutes', 'converted'),
  (md5('cinema-demo:hold:6')::uuid, md5('cinema-demo:show:2')::uuid, md5('cinema-demo:user:5')::uuid, NULL, now() - interval '2 hours 55 minutes', 'converted'),
  (md5('cinema-demo:hold:7')::uuid, md5('cinema-demo:show:2')::uuid, NULL, encode(digest('demo-hold-7','sha256'),'hex'), now() - interval '2 hours 55 minutes', 'converted'),
  (md5('cinema-demo:hold:8')::uuid, md5('cinema-demo:show:2')::uuid, md5('cinema-demo:user:5')::uuid, NULL, now() - interval '2 hours 55 minutes', 'converted'),
  (md5('cinema-demo:hold:9')::uuid, md5('cinema-demo:show:2')::uuid, NULL, encode(digest('demo-hold-9','sha256'),'hex'), now() - interval '2 hours 55 minutes', 'converted'),
  (md5('cinema-demo:hold:10')::uuid, md5('cinema-demo:show:2')::uuid, md5('cinema-demo:user:5')::uuid, NULL, now() - interval '2 hours 55 minutes', 'converted')
ON CONFLICT DO NOTHING;

INSERT INTO bookings (id, showtime_id, hold_id, user_id, booking_code_hash, contact_name, contact_email, status, total_vnd, expires_at, confirmed_at, cancelled_at, created_at) VALUES
  (md5('cinema-demo:booking:1')::uuid, md5('cinema-demo:show:1')::uuid, md5('cinema-demo:hold:1')::uuid, md5('cinema-demo:user:2')::uuid, encode(digest('cinema-demo-booking-1','sha256'),'hex'), 'Người đặt 1', 'user@cinema.example', 'confirmed', 160000, now() - interval '23 hours 55 minutes', now() - interval '1 day', NULL, now() - interval '1 day'),
  (md5('cinema-demo:booking:2')::uuid, md5('cinema-demo:show:1')::uuid, md5('cinema-demo:hold:2')::uuid, md5('cinema-demo:user:2')::uuid, encode(digest('cinema-demo-booking-2','sha256'),'hex'), 'Người đặt 2', 'user@cinema.example', 'confirmed', 165000, now() - interval '23 hours 55 minutes', now() - interval '1 day', NULL, now() - interval '1 day'),
  (md5('cinema-demo:booking:3')::uuid, md5('cinema-demo:show:1')::uuid, md5('cinema-demo:hold:3')::uuid, md5('cinema-demo:user:2')::uuid, encode(digest('cinema-demo-booking-3','sha256'),'hex'), 'Người đặt 3', 'user@cinema.example', 'confirmed', 205000, now() - interval '23 hours 55 minutes', now() - interval '1 day', NULL, now() - interval '1 day'),
  (md5('cinema-demo:booking:4')::uuid, md5('cinema-demo:show:1')::uuid, md5('cinema-demo:hold:4')::uuid, md5('cinema-demo:user:2')::uuid, encode(digest('cinema-demo-booking-4','sha256'),'hex'), 'Người đặt 4', 'user@cinema.example', 'confirmed', 210000, now() - interval '23 hours 55 minutes', now() - interval '1 day', NULL, now() - interval '1 day'),
  (md5('cinema-demo:booking:5')::uuid, md5('cinema-demo:show:1')::uuid, md5('cinema-demo:hold:5')::uuid, md5('cinema-demo:user:2')::uuid, encode(digest('cinema-demo-booking-5','sha256'),'hex'), 'Người đặt 5', 'user@cinema.example', 'confirmed', 255000, now() - interval '23 hours 55 minutes', now() - interval '1 day', NULL, now() - interval '1 day'),
  (md5('cinema-demo:booking:6')::uuid, md5('cinema-demo:show:2')::uuid, md5('cinema-demo:hold:6')::uuid, md5('cinema-demo:user:5')::uuid, encode(digest('cinema-demo-booking-6','sha256'),'hex'), 'Người đặt 6', 'customer02@cinema.example', 'cancelled', 160000, now() - interval '2 hours 55 minutes', now() - interval '3 hours', now() - interval '2 hours', now() - interval '3 hours'),
  (md5('cinema-demo:booking:7')::uuid, md5('cinema-demo:show:2')::uuid, md5('cinema-demo:hold:7')::uuid, NULL, encode(digest('cinema-demo-booking-7','sha256'),'hex'), 'Người đặt 7', 'guest-7@cinema.example', 'cancelled', 165000, now() - interval '2 hours 55 minutes', now() - interval '3 hours', now() - interval '2 hours', now() - interval '3 hours'),
  (md5('cinema-demo:booking:8')::uuid, md5('cinema-demo:show:2')::uuid, md5('cinema-demo:hold:8')::uuid, md5('cinema-demo:user:5')::uuid, encode(digest('cinema-demo-booking-8','sha256'),'hex'), 'Người đặt 8', 'customer02@cinema.example', 'cancelled', 205000, now() - interval '2 hours 55 minutes', now() - interval '3 hours', now() - interval '2 hours', now() - interval '3 hours'),
  (md5('cinema-demo:booking:9')::uuid, md5('cinema-demo:show:2')::uuid, md5('cinema-demo:hold:9')::uuid, NULL, encode(digest('cinema-demo-booking-9','sha256'),'hex'), 'Người đặt 9', 'guest-9@cinema.example', 'cancelled', 210000, now() - interval '2 hours 55 minutes', now() - interval '3 hours', now() - interval '2 hours', now() - interval '3 hours'),
  (md5('cinema-demo:booking:10')::uuid, md5('cinema-demo:show:2')::uuid, md5('cinema-demo:hold:10')::uuid, md5('cinema-demo:user:5')::uuid, encode(digest('cinema-demo-booking-10','sha256'),'hex'), 'Người đặt 10', 'customer02@cinema.example', 'cancelled', 255000, now() - interval '2 hours 55 minutes', now() - interval '3 hours', now() - interval '2 hours', now() - interval '3 hours')
ON CONFLICT DO NOTHING;

INSERT INTO showtime_seats (showtime_id, seat_id, auditorium_id, status, booking_id) VALUES
  (md5('cinema-demo:show:1')::uuid, md5('cinema-demo:seat:1')::uuid, md5('cinema-demo:room:1')::uuid, 'sold', md5('cinema-demo:booking:1')::uuid),
  (md5('cinema-demo:show:1')::uuid, md5('cinema-demo:seat:2')::uuid, md5('cinema-demo:room:1')::uuid, 'sold', md5('cinema-demo:booking:2')::uuid),
  (md5('cinema-demo:show:1')::uuid, md5('cinema-demo:seat:3')::uuid, md5('cinema-demo:room:1')::uuid, 'sold', md5('cinema-demo:booking:3')::uuid),
  (md5('cinema-demo:show:1')::uuid, md5('cinema-demo:seat:4')::uuid, md5('cinema-demo:room:1')::uuid, 'sold', md5('cinema-demo:booking:4')::uuid),
  (md5('cinema-demo:show:1')::uuid, md5('cinema-demo:seat:5')::uuid, md5('cinema-demo:room:1')::uuid, 'sold', md5('cinema-demo:booking:5')::uuid),
  (md5('cinema-demo:show:2')::uuid, md5('cinema-demo:seat:1')::uuid, md5('cinema-demo:room:1')::uuid, 'available', NULL),
  (md5('cinema-demo:show:2')::uuid, md5('cinema-demo:seat:2')::uuid, md5('cinema-demo:room:1')::uuid, 'available', NULL),
  (md5('cinema-demo:show:2')::uuid, md5('cinema-demo:seat:3')::uuid, md5('cinema-demo:room:1')::uuid, 'available', NULL),
  (md5('cinema-demo:show:2')::uuid, md5('cinema-demo:seat:4')::uuid, md5('cinema-demo:room:1')::uuid, 'available', NULL),
  (md5('cinema-demo:show:2')::uuid, md5('cinema-demo:seat:5')::uuid, md5('cinema-demo:room:1')::uuid, 'available', NULL)
ON CONFLICT DO NOTHING;

INSERT INTO booking_seats (booking_id, showtime_id, seat_id, seat_label, seat_kind, price_vnd) VALUES
  (md5('cinema-demo:booking:1')::uuid, md5('cinema-demo:show:1')::uuid, md5('cinema-demo:seat:1')::uuid, 'A1', 'standard', 95000),
  (md5('cinema-demo:booking:2')::uuid, md5('cinema-demo:show:1')::uuid, md5('cinema-demo:seat:2')::uuid, 'A2', 'standard', 95000),
  (md5('cinema-demo:booking:3')::uuid, md5('cinema-demo:show:1')::uuid, md5('cinema-demo:seat:3')::uuid, 'A3', 'vip', 130000),
  (md5('cinema-demo:booking:4')::uuid, md5('cinema-demo:show:1')::uuid, md5('cinema-demo:seat:4')::uuid, 'A4', 'vip', 130000),
  (md5('cinema-demo:booking:5')::uuid, md5('cinema-demo:show:1')::uuid, md5('cinema-demo:seat:5')::uuid, 'A5', 'couple', 170000),
  (md5('cinema-demo:booking:6')::uuid, md5('cinema-demo:show:2')::uuid, md5('cinema-demo:seat:1')::uuid, 'A1', 'standard', 95000),
  (md5('cinema-demo:booking:7')::uuid, md5('cinema-demo:show:2')::uuid, md5('cinema-demo:seat:2')::uuid, 'A2', 'standard', 95000),
  (md5('cinema-demo:booking:8')::uuid, md5('cinema-demo:show:2')::uuid, md5('cinema-demo:seat:3')::uuid, 'A3', 'vip', 130000),
  (md5('cinema-demo:booking:9')::uuid, md5('cinema-demo:show:2')::uuid, md5('cinema-demo:seat:4')::uuid, 'A4', 'vip', 130000),
  (md5('cinema-demo:booking:10')::uuid, md5('cinema-demo:show:2')::uuid, md5('cinema-demo:seat:5')::uuid, 'A5', 'couple', 170000)
ON CONFLICT DO NOTHING;

INSERT INTO booking_combos (booking_id, combo_id, name, unit_price_vnd, quantity) VALUES
  (md5('cinema-demo:booking:1')::uuid, md5('cinema-demo:combo:1')::uuid, 'Combo Bắp Nước 1', 65000, 1),
  (md5('cinema-demo:booking:2')::uuid, md5('cinema-demo:combo:2')::uuid, 'Combo Bắp Nước 2', 70000, 1),
  (md5('cinema-demo:booking:3')::uuid, md5('cinema-demo:combo:3')::uuid, 'Combo Bắp Nước 3', 75000, 1),
  (md5('cinema-demo:booking:4')::uuid, md5('cinema-demo:combo:4')::uuid, 'Combo Bắp Nước 4', 80000, 1),
  (md5('cinema-demo:booking:5')::uuid, md5('cinema-demo:combo:5')::uuid, 'Combo Bắp Nước 5', 85000, 1),
  (md5('cinema-demo:booking:6')::uuid, md5('cinema-demo:combo:1')::uuid, 'Combo Bắp Nước 1', 65000, 1),
  (md5('cinema-demo:booking:7')::uuid, md5('cinema-demo:combo:2')::uuid, 'Combo Bắp Nước 2', 70000, 1),
  (md5('cinema-demo:booking:8')::uuid, md5('cinema-demo:combo:3')::uuid, 'Combo Bắp Nước 3', 75000, 1),
  (md5('cinema-demo:booking:9')::uuid, md5('cinema-demo:combo:4')::uuid, 'Combo Bắp Nước 4', 80000, 1),
  (md5('cinema-demo:booking:10')::uuid, md5('cinema-demo:combo:5')::uuid, 'Combo Bắp Nước 5', 85000, 1)
ON CONFLICT DO NOTHING;

INSERT INTO payment_attempts (id, booking_id, external_payment_id, amount_vnd, status, created_at) VALUES
  (md5('cinema-demo:attempt:1')::uuid, md5('cinema-demo:booking:1')::uuid, md5('cinema-demo:payment:1')::uuid, 160000, 'succeeded', now() - interval '1 day'),
  (md5('cinema-demo:attempt:2')::uuid, md5('cinema-demo:booking:2')::uuid, md5('cinema-demo:payment:2')::uuid, 165000, 'succeeded', now() - interval '1 day'),
  (md5('cinema-demo:attempt:3')::uuid, md5('cinema-demo:booking:3')::uuid, md5('cinema-demo:payment:3')::uuid, 205000, 'succeeded', now() - interval '1 day'),
  (md5('cinema-demo:attempt:4')::uuid, md5('cinema-demo:booking:4')::uuid, md5('cinema-demo:payment:4')::uuid, 210000, 'succeeded', now() - interval '1 day'),
  (md5('cinema-demo:attempt:5')::uuid, md5('cinema-demo:booking:5')::uuid, md5('cinema-demo:payment:5')::uuid, 255000, 'succeeded', now() - interval '1 day'),
  (md5('cinema-demo:attempt:6')::uuid, md5('cinema-demo:booking:6')::uuid, md5('cinema-demo:payment:6')::uuid, 160000, 'refunded', now() - interval '3 hours'),
  (md5('cinema-demo:attempt:7')::uuid, md5('cinema-demo:booking:7')::uuid, md5('cinema-demo:payment:7')::uuid, 165000, 'refunded', now() - interval '3 hours'),
  (md5('cinema-demo:attempt:8')::uuid, md5('cinema-demo:booking:8')::uuid, md5('cinema-demo:payment:8')::uuid, 205000, 'refunded', now() - interval '3 hours'),
  (md5('cinema-demo:attempt:9')::uuid, md5('cinema-demo:booking:9')::uuid, md5('cinema-demo:payment:9')::uuid, 210000, 'refunded', now() - interval '3 hours'),
  (md5('cinema-demo:attempt:10')::uuid, md5('cinema-demo:booking:10')::uuid, md5('cinema-demo:payment:10')::uuid, 255000, 'refunded', now() - interval '3 hours')
ON CONFLICT DO NOTHING;

INSERT INTO processed_payment_events (event_id, payment_attempt_id, kind, payload, processed_at) VALUES
  (md5('cinema-demo:event:1')::uuid, md5('cinema-demo:attempt:1')::uuid, 'payment.succeeded', jsonb_build_object('eventId', md5('cinema-demo:event:1')::uuid, 'type', 'payment.succeeded', 'paymentId', md5('cinema-demo:payment:1')::uuid, 'bookingRef', md5('cinema-demo:booking:1')::uuid, 'amountVnd', 160000, 'currency', 'VND'), now() - interval '1 day'),
  (md5('cinema-demo:event:2')::uuid, md5('cinema-demo:attempt:2')::uuid, 'payment.succeeded', jsonb_build_object('eventId', md5('cinema-demo:event:2')::uuid, 'type', 'payment.succeeded', 'paymentId', md5('cinema-demo:payment:2')::uuid, 'bookingRef', md5('cinema-demo:booking:2')::uuid, 'amountVnd', 165000, 'currency', 'VND'), now() - interval '1 day'),
  (md5('cinema-demo:event:3')::uuid, md5('cinema-demo:attempt:3')::uuid, 'payment.succeeded', jsonb_build_object('eventId', md5('cinema-demo:event:3')::uuid, 'type', 'payment.succeeded', 'paymentId', md5('cinema-demo:payment:3')::uuid, 'bookingRef', md5('cinema-demo:booking:3')::uuid, 'amountVnd', 205000, 'currency', 'VND'), now() - interval '1 day'),
  (md5('cinema-demo:event:4')::uuid, md5('cinema-demo:attempt:4')::uuid, 'payment.succeeded', jsonb_build_object('eventId', md5('cinema-demo:event:4')::uuid, 'type', 'payment.succeeded', 'paymentId', md5('cinema-demo:payment:4')::uuid, 'bookingRef', md5('cinema-demo:booking:4')::uuid, 'amountVnd', 210000, 'currency', 'VND'), now() - interval '1 day'),
  (md5('cinema-demo:event:5')::uuid, md5('cinema-demo:attempt:5')::uuid, 'payment.succeeded', jsonb_build_object('eventId', md5('cinema-demo:event:5')::uuid, 'type', 'payment.succeeded', 'paymentId', md5('cinema-demo:payment:5')::uuid, 'bookingRef', md5('cinema-demo:booking:5')::uuid, 'amountVnd', 255000, 'currency', 'VND'), now() - interval '1 day'),
  (md5('cinema-demo:event:6')::uuid, md5('cinema-demo:attempt:6')::uuid, 'refund.succeeded', jsonb_build_object('eventId', md5('cinema-demo:event:6')::uuid, 'type', 'refund.succeeded', 'paymentId', md5('cinema-demo:payment:6')::uuid, 'bookingRef', md5('cinema-demo:booking:6')::uuid, 'amountVnd', 160000, 'currency', 'VND', 'refundId', md5('cinema-demo:refund:6')::uuid), now() - interval '2 hours'),
  (md5('cinema-demo:event:7')::uuid, md5('cinema-demo:attempt:7')::uuid, 'refund.succeeded', jsonb_build_object('eventId', md5('cinema-demo:event:7')::uuid, 'type', 'refund.succeeded', 'paymentId', md5('cinema-demo:payment:7')::uuid, 'bookingRef', md5('cinema-demo:booking:7')::uuid, 'amountVnd', 165000, 'currency', 'VND', 'refundId', md5('cinema-demo:refund:7')::uuid), now() - interval '2 hours'),
  (md5('cinema-demo:event:8')::uuid, md5('cinema-demo:attempt:8')::uuid, 'refund.succeeded', jsonb_build_object('eventId', md5('cinema-demo:event:8')::uuid, 'type', 'refund.succeeded', 'paymentId', md5('cinema-demo:payment:8')::uuid, 'bookingRef', md5('cinema-demo:booking:8')::uuid, 'amountVnd', 205000, 'currency', 'VND', 'refundId', md5('cinema-demo:refund:8')::uuid), now() - interval '2 hours'),
  (md5('cinema-demo:event:9')::uuid, md5('cinema-demo:attempt:9')::uuid, 'refund.succeeded', jsonb_build_object('eventId', md5('cinema-demo:event:9')::uuid, 'type', 'refund.succeeded', 'paymentId', md5('cinema-demo:payment:9')::uuid, 'bookingRef', md5('cinema-demo:booking:9')::uuid, 'amountVnd', 210000, 'currency', 'VND', 'refundId', md5('cinema-demo:refund:9')::uuid), now() - interval '2 hours'),
  (md5('cinema-demo:event:10')::uuid, md5('cinema-demo:attempt:10')::uuid, 'refund.succeeded', jsonb_build_object('eventId', md5('cinema-demo:event:10')::uuid, 'type', 'refund.succeeded', 'paymentId', md5('cinema-demo:payment:10')::uuid, 'bookingRef', md5('cinema-demo:booking:10')::uuid, 'amountVnd', 255000, 'currency', 'VND', 'refundId', md5('cinema-demo:refund:10')::uuid), now() - interval '2 hours')
ON CONFLICT DO NOTHING;

INSERT INTO outbox_events (id, kind, payload, status, attempts, next_attempt_at, created_at) VALUES
  (md5('cinema-demo:outbox:1')::uuid, 'ticket_issued', jsonb_build_object('bookingId', md5('cinema-demo:booking:1')::uuid, 'recipient', 'user@cinema.example'), 'sent', 1, now() - interval '1 day', now() - interval '1 day'),
  (md5('cinema-demo:outbox:2')::uuid, 'ticket_issued', jsonb_build_object('bookingId', md5('cinema-demo:booking:2')::uuid, 'recipient', 'user@cinema.example'), 'sent', 1, now() - interval '1 day', now() - interval '1 day'),
  (md5('cinema-demo:outbox:3')::uuid, 'ticket_issued', jsonb_build_object('bookingId', md5('cinema-demo:booking:3')::uuid, 'recipient', 'user@cinema.example'), 'sent', 1, now() - interval '1 day', now() - interval '1 day'),
  (md5('cinema-demo:outbox:4')::uuid, 'ticket_issued', jsonb_build_object('bookingId', md5('cinema-demo:booking:4')::uuid, 'recipient', 'user@cinema.example'), 'sent', 1, now() - interval '1 day', now() - interval '1 day'),
  (md5('cinema-demo:outbox:5')::uuid, 'ticket_issued', jsonb_build_object('bookingId', md5('cinema-demo:booking:5')::uuid, 'recipient', 'user@cinema.example'), 'sent', 1, now() - interval '1 day', now() - interval '1 day')
ON CONFLICT DO NOTHING;

INSERT INTO tickets (id, booking_id, seat_id, qr_token_hash, status) VALUES
  (md5('cinema-demo:ticket:1')::uuid, md5('cinema-demo:booking:1')::uuid, md5('cinema-demo:seat:1')::uuid, encode(digest('cinema-demo-ticket-1','sha256'),'hex'), 'checked_in'),
  (md5('cinema-demo:ticket:2')::uuid, md5('cinema-demo:booking:2')::uuid, md5('cinema-demo:seat:2')::uuid, encode(digest('cinema-demo-ticket-2','sha256'),'hex'), 'checked_in'),
  (md5('cinema-demo:ticket:3')::uuid, md5('cinema-demo:booking:3')::uuid, md5('cinema-demo:seat:3')::uuid, encode(digest('cinema-demo-ticket-3','sha256'),'hex'), 'checked_in'),
  (md5('cinema-demo:ticket:4')::uuid, md5('cinema-demo:booking:4')::uuid, md5('cinema-demo:seat:4')::uuid, encode(digest('cinema-demo-ticket-4','sha256'),'hex'), 'checked_in'),
  (md5('cinema-demo:ticket:5')::uuid, md5('cinema-demo:booking:5')::uuid, md5('cinema-demo:seat:5')::uuid, encode(digest('cinema-demo-ticket-5','sha256'),'hex'), 'checked_in'),
  (md5('cinema-demo:ticket:6')::uuid, md5('cinema-demo:booking:6')::uuid, md5('cinema-demo:seat:1')::uuid, encode(digest('cinema-demo-ticket-6','sha256'),'hex'), 'void'),
  (md5('cinema-demo:ticket:7')::uuid, md5('cinema-demo:booking:7')::uuid, md5('cinema-demo:seat:2')::uuid, encode(digest('cinema-demo-ticket-7','sha256'),'hex'), 'void'),
  (md5('cinema-demo:ticket:8')::uuid, md5('cinema-demo:booking:8')::uuid, md5('cinema-demo:seat:3')::uuid, encode(digest('cinema-demo-ticket-8','sha256'),'hex'), 'void'),
  (md5('cinema-demo:ticket:9')::uuid, md5('cinema-demo:booking:9')::uuid, md5('cinema-demo:seat:4')::uuid, encode(digest('cinema-demo-ticket-9','sha256'),'hex'), 'void'),
  (md5('cinema-demo:ticket:10')::uuid, md5('cinema-demo:booking:10')::uuid, md5('cinema-demo:seat:5')::uuid, encode(digest('cinema-demo-ticket-10','sha256'),'hex'), 'void')
ON CONFLICT DO NOTHING;

INSERT INTO ticket_check_ins (id, ticket_id, staff_id, checked_in_at) VALUES
  (md5('cinema-demo:checkin:1')::uuid, md5('cinema-demo:ticket:1')::uuid, md5('cinema-demo:user:3')::uuid, now() - interval '5 minutes'),
  (md5('cinema-demo:checkin:2')::uuid, md5('cinema-demo:ticket:2')::uuid, md5('cinema-demo:user:3')::uuid, now() - interval '5 minutes'),
  (md5('cinema-demo:checkin:3')::uuid, md5('cinema-demo:ticket:3')::uuid, md5('cinema-demo:user:3')::uuid, now() - interval '5 minutes'),
  (md5('cinema-demo:checkin:4')::uuid, md5('cinema-demo:ticket:4')::uuid, md5('cinema-demo:user:3')::uuid, now() - interval '5 minutes'),
  (md5('cinema-demo:checkin:5')::uuid, md5('cinema-demo:ticket:5')::uuid, md5('cinema-demo:user:3')::uuid, now() - interval '5 minutes')
ON CONFLICT DO NOTHING;
COMMIT;
-- CORE END

-- PAYMENT BEGIN
BEGIN;
SET LOCAL search_path = cinema_payment, pg_catalog;

INSERT INTO payments (id, booking_ref, amount_vnd, status, idempotency_key, expires_at, created_at) VALUES
  (md5('cinema-demo:payment:1')::uuid, md5('cinema-demo:booking:1')::uuid, 160000, 'succeeded', 'demo-payment-1', now() - interval '23 hours 55 minutes', now() - interval '1 day'),
  (md5('cinema-demo:payment:2')::uuid, md5('cinema-demo:booking:2')::uuid, 165000, 'succeeded', 'demo-payment-2', now() - interval '23 hours 55 minutes', now() - interval '1 day'),
  (md5('cinema-demo:payment:3')::uuid, md5('cinema-demo:booking:3')::uuid, 205000, 'succeeded', 'demo-payment-3', now() - interval '23 hours 55 minutes', now() - interval '1 day'),
  (md5('cinema-demo:payment:4')::uuid, md5('cinema-demo:booking:4')::uuid, 210000, 'succeeded', 'demo-payment-4', now() - interval '23 hours 55 minutes', now() - interval '1 day'),
  (md5('cinema-demo:payment:5')::uuid, md5('cinema-demo:booking:5')::uuid, 255000, 'succeeded', 'demo-payment-5', now() - interval '23 hours 55 minutes', now() - interval '1 day'),
  (md5('cinema-demo:payment:6')::uuid, md5('cinema-demo:booking:6')::uuid, 160000, 'refunded', 'demo-payment-6', now() - interval '2 hours 55 minutes', now() - interval '3 hours'),
  (md5('cinema-demo:payment:7')::uuid, md5('cinema-demo:booking:7')::uuid, 165000, 'refunded', 'demo-payment-7', now() - interval '2 hours 55 minutes', now() - interval '3 hours'),
  (md5('cinema-demo:payment:8')::uuid, md5('cinema-demo:booking:8')::uuid, 205000, 'refunded', 'demo-payment-8', now() - interval '2 hours 55 minutes', now() - interval '3 hours'),
  (md5('cinema-demo:payment:9')::uuid, md5('cinema-demo:booking:9')::uuid, 210000, 'refunded', 'demo-payment-9', now() - interval '2 hours 55 minutes', now() - interval '3 hours'),
  (md5('cinema-demo:payment:10')::uuid, md5('cinema-demo:booking:10')::uuid, 255000, 'refunded', 'demo-payment-10', now() - interval '2 hours 55 minutes', now() - interval '3 hours')
ON CONFLICT DO NOTHING;

INSERT INTO refunds (id, payment_id, amount_vnd, reason, status, idempotency_key, created_at) VALUES
  (md5('cinema-demo:refund:6')::uuid, md5('cinema-demo:payment:6')::uuid, 160000, 'booking_cancellation', 'succeeded', 'demo-refund-6', now() - interval '2 hours'),
  (md5('cinema-demo:refund:7')::uuid, md5('cinema-demo:payment:7')::uuid, 165000, 'booking_cancellation', 'succeeded', 'demo-refund-7', now() - interval '2 hours'),
  (md5('cinema-demo:refund:8')::uuid, md5('cinema-demo:payment:8')::uuid, 205000, 'booking_cancellation', 'succeeded', 'demo-refund-8', now() - interval '2 hours'),
  (md5('cinema-demo:refund:9')::uuid, md5('cinema-demo:payment:9')::uuid, 210000, 'booking_cancellation', 'succeeded', 'demo-refund-9', now() - interval '2 hours'),
  (md5('cinema-demo:refund:10')::uuid, md5('cinema-demo:payment:10')::uuid, 255000, 'booking_cancellation', 'succeeded', 'demo-refund-10', now() - interval '2 hours')
ON CONFLICT DO NOTHING;

INSERT INTO webhook_deliveries (id, event_id, payment_id, body, status, attempts, next_attempt_at, delivered_at) VALUES
  (md5('cinema-demo:delivery:1')::uuid, md5('cinema-demo:event:1')::uuid, md5('cinema-demo:payment:1')::uuid, jsonb_build_object('eventId', md5('cinema-demo:event:1')::uuid, 'type', 'payment.succeeded', 'paymentId', md5('cinema-demo:payment:1')::uuid, 'bookingRef', md5('cinema-demo:booking:1')::uuid, 'amountVnd', 160000, 'currency', 'VND'), 'sent', 1, now() - interval '1 day', now() - interval '1 day'),
  (md5('cinema-demo:delivery:2')::uuid, md5('cinema-demo:event:2')::uuid, md5('cinema-demo:payment:2')::uuid, jsonb_build_object('eventId', md5('cinema-demo:event:2')::uuid, 'type', 'payment.succeeded', 'paymentId', md5('cinema-demo:payment:2')::uuid, 'bookingRef', md5('cinema-demo:booking:2')::uuid, 'amountVnd', 165000, 'currency', 'VND'), 'sent', 1, now() - interval '1 day', now() - interval '1 day'),
  (md5('cinema-demo:delivery:3')::uuid, md5('cinema-demo:event:3')::uuid, md5('cinema-demo:payment:3')::uuid, jsonb_build_object('eventId', md5('cinema-demo:event:3')::uuid, 'type', 'payment.succeeded', 'paymentId', md5('cinema-demo:payment:3')::uuid, 'bookingRef', md5('cinema-demo:booking:3')::uuid, 'amountVnd', 205000, 'currency', 'VND'), 'sent', 1, now() - interval '1 day', now() - interval '1 day'),
  (md5('cinema-demo:delivery:4')::uuid, md5('cinema-demo:event:4')::uuid, md5('cinema-demo:payment:4')::uuid, jsonb_build_object('eventId', md5('cinema-demo:event:4')::uuid, 'type', 'payment.succeeded', 'paymentId', md5('cinema-demo:payment:4')::uuid, 'bookingRef', md5('cinema-demo:booking:4')::uuid, 'amountVnd', 210000, 'currency', 'VND'), 'sent', 1, now() - interval '1 day', now() - interval '1 day'),
  (md5('cinema-demo:delivery:5')::uuid, md5('cinema-demo:event:5')::uuid, md5('cinema-demo:payment:5')::uuid, jsonb_build_object('eventId', md5('cinema-demo:event:5')::uuid, 'type', 'payment.succeeded', 'paymentId', md5('cinema-demo:payment:5')::uuid, 'bookingRef', md5('cinema-demo:booking:5')::uuid, 'amountVnd', 255000, 'currency', 'VND'), 'sent', 1, now() - interval '1 day', now() - interval '1 day'),
  (md5('cinema-demo:delivery:6')::uuid, md5('cinema-demo:event:6')::uuid, md5('cinema-demo:payment:6')::uuid, jsonb_build_object('eventId', md5('cinema-demo:event:6')::uuid, 'type', 'refund.succeeded', 'paymentId', md5('cinema-demo:payment:6')::uuid, 'bookingRef', md5('cinema-demo:booking:6')::uuid, 'amountVnd', 160000, 'currency', 'VND', 'refundId', md5('cinema-demo:refund:6')::uuid), 'sent', 1, now() - interval '2 hours', now() - interval '2 hours'),
  (md5('cinema-demo:delivery:7')::uuid, md5('cinema-demo:event:7')::uuid, md5('cinema-demo:payment:7')::uuid, jsonb_build_object('eventId', md5('cinema-demo:event:7')::uuid, 'type', 'refund.succeeded', 'paymentId', md5('cinema-demo:payment:7')::uuid, 'bookingRef', md5('cinema-demo:booking:7')::uuid, 'amountVnd', 165000, 'currency', 'VND', 'refundId', md5('cinema-demo:refund:7')::uuid), 'sent', 1, now() - interval '2 hours', now() - interval '2 hours'),
  (md5('cinema-demo:delivery:8')::uuid, md5('cinema-demo:event:8')::uuid, md5('cinema-demo:payment:8')::uuid, jsonb_build_object('eventId', md5('cinema-demo:event:8')::uuid, 'type', 'refund.succeeded', 'paymentId', md5('cinema-demo:payment:8')::uuid, 'bookingRef', md5('cinema-demo:booking:8')::uuid, 'amountVnd', 205000, 'currency', 'VND', 'refundId', md5('cinema-demo:refund:8')::uuid), 'sent', 1, now() - interval '2 hours', now() - interval '2 hours'),
  (md5('cinema-demo:delivery:9')::uuid, md5('cinema-demo:event:9')::uuid, md5('cinema-demo:payment:9')::uuid, jsonb_build_object('eventId', md5('cinema-demo:event:9')::uuid, 'type', 'refund.succeeded', 'paymentId', md5('cinema-demo:payment:9')::uuid, 'bookingRef', md5('cinema-demo:booking:9')::uuid, 'amountVnd', 210000, 'currency', 'VND', 'refundId', md5('cinema-demo:refund:9')::uuid), 'sent', 1, now() - interval '2 hours', now() - interval '2 hours'),
  (md5('cinema-demo:delivery:10')::uuid, md5('cinema-demo:event:10')::uuid, md5('cinema-demo:payment:10')::uuid, jsonb_build_object('eventId', md5('cinema-demo:event:10')::uuid, 'type', 'refund.succeeded', 'paymentId', md5('cinema-demo:payment:10')::uuid, 'bookingRef', md5('cinema-demo:booking:10')::uuid, 'amountVnd', 255000, 'currency', 'VND', 'refundId', md5('cinema-demo:refund:10')::uuid), 'sent', 1, now() - interval '2 hours', now() - interval '2 hours')
ON CONFLICT DO NOTHING;
COMMIT;
-- PAYMENT END

-- NOTIFICATION BEGIN
BEGIN;
SET LOCAL search_path = cinema_notification, pg_catalog;

INSERT INTO notification_jobs (id, idempotency_key, template, recipient, data, status, attempts, next_attempt_at, sent_at) VALUES
  (md5('cinema-demo:notification:1')::uuid, 'demo-notification-1', 'ticket_issued', 'user@cinema.example', jsonb_build_object('bookingId', md5('cinema-demo:booking:1')::uuid, 'tickets', jsonb_build_array(jsonb_build_object('seatLabel', 'A1', 'ticketId', md5('cinema-demo:ticket:1')::uuid))), 'sent', 1, now() - interval '1 day', now() - interval '1 day'),
  (md5('cinema-demo:notification:2')::uuid, 'demo-notification-2', 'ticket_issued', 'user@cinema.example', jsonb_build_object('bookingId', md5('cinema-demo:booking:2')::uuid, 'tickets', jsonb_build_array(jsonb_build_object('seatLabel', 'A2', 'ticketId', md5('cinema-demo:ticket:2')::uuid))), 'sent', 1, now() - interval '1 day', now() - interval '1 day'),
  (md5('cinema-demo:notification:3')::uuid, 'demo-notification-3', 'ticket_issued', 'user@cinema.example', jsonb_build_object('bookingId', md5('cinema-demo:booking:3')::uuid, 'tickets', jsonb_build_array(jsonb_build_object('seatLabel', 'A3', 'ticketId', md5('cinema-demo:ticket:3')::uuid))), 'sent', 1, now() - interval '1 day', now() - interval '1 day'),
  (md5('cinema-demo:notification:4')::uuid, 'demo-notification-4', 'ticket_issued', 'user@cinema.example', jsonb_build_object('bookingId', md5('cinema-demo:booking:4')::uuid, 'tickets', jsonb_build_array(jsonb_build_object('seatLabel', 'A4', 'ticketId', md5('cinema-demo:ticket:4')::uuid))), 'sent', 1, now() - interval '1 day', now() - interval '1 day'),
  (md5('cinema-demo:notification:5')::uuid, 'demo-notification-5', 'ticket_issued', 'user@cinema.example', jsonb_build_object('bookingId', md5('cinema-demo:booking:5')::uuid, 'tickets', jsonb_build_array(jsonb_build_object('seatLabel', 'A5', 'ticketId', md5('cinema-demo:ticket:5')::uuid))), 'sent', 1, now() - interval '1 day', now() - interval '1 day')
ON CONFLICT DO NOTHING;
COMMIT;
-- NOTIFICATION END
