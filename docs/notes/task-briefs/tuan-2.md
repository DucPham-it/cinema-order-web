# Phiếu giao việc Tuần 2 · Triển khai module độc lập

**12 giờ/người · 60 giờ-người.** Các API viết tương đối với `/api/v1` trừ `/health`. Dấu ngoặc nhọn giữa tên file là các file riêng có cùng thư mục. File đã có thì sửa, file mới thì tạo khi module cần. Các file kiểm thử module ở `services/<dịch-vụ>/test/`. Giữ DB test tách môi trường cloud. Frontend do AI sinh, N5 nghiệm thu và lắp ghép.

**Phụ thuộc trong tuần** — N2 bàn giao seed/rạp/phim/suất sớm; N1 đưa middleware mẫu cho N2/N3; N3 và N4 test bằng request mẫu đã thống nhất.

## N1 · Auth và quản trị người dùng

**Nhánh** `feat/auth-users` · **Review** N3 + N4.

**File giao việc**

- `services/api/src/modules/auth/{routes,service,repository}.js`
- `services/api/src/modules/users/{routes,service,repository}.js`
- `services/api/src/app.js`
- `contracts/openapi.core.json`

**API hoặc màn hình** — POST /auth/{register,email-verifications,email-verification-requests,login,refresh,logout,password-reset-requests,password-resets}; GET/PUT /me; GET /admin/users; PUT /admin/users/{userId}/access.

**Nghiệm thu trước khi duyệt PR** — Dùng DB test và Notification mock. Đăng ký → xác thực → login; sai mật khẩu 401; refresh được xoay và logout thu hồi; Customer không tự nâng quyền, Manager rạp A không truy cập rạp B; response tránh lộ hash/token refresh.

## N2 · CRUD, sơ đồ ghế và lịch chiếu

**Nhánh** `feat/catalog-showtimes-admin` · **Review** N1 + N3.

**File giao việc**

- `services/api/src/modules/catalog/{routes,repository}.js`
- `services/api/src/modules/showtimes/{routes,service,repository}.js`
- `database/seed.sql`
- `contracts/openapi.core.json`

**API hoặc màn hình** — CRUD /admin/{cinemas,auditoriums,seats,genres,movies,price-rules,combos}; operations /operations/showtimes và /{showtimeId}/status; giữ các GET public đã có.

**Nghiệm thu trước khi duyệt PR** — Admin tạo đủ cấu hình và Manager chỉ quản lý rạp mình. Hai lịch giao nhau cùng phòng trả 409; mở bán tạo đúng kho ghế; giá và trailer khớp truy vấn public. Có seed suất tương lai và API test với DB riêng.

## N3 · Giữ ghế, đơn và QR

**Nhánh** `feat/booking-and-tickets` · **Review** N2 + N4.

**File giao việc**

- `services/api/src/modules/booking/{routes,service,repository}.js`
- `services/api/src/modules/tickets/{routes,service,repository}.js`
- `services/api/src/app.js`
- `database/002_booking_constraints.sql`
- `contracts/openapi.core.json`

**API hoặc màn hình** — POST /showtimes/{showtimeId}/holds; DELETE /holds/{holdId}; POST /bookings, /bookings/lookup, /bookings/{bookingId}/cancellations; GET /me/bookings, /bookings/{bookingId}, /operations/bookings; POST /ticket-check-ins; GET /operations/showtimes/{showtimeId}/attendees.

**Nghiệm thu trước khi duyệt PR** — Dùng gateway mock. Hai lệnh giữ cùng ghế chỉ có một lệnh thành công; giữ nhiều ghế thành công toàn bộ hoặc rollback; expired có thể giữ lại theo transaction. Chủ đơn xem được, sai chủ bị chặn; giá tính server; test giữ/lặp request, hủy và QR hai lần. Tạo migration bổ sung khi chốt idempotency; đồng bộ hướng nạp local cùng N5.

## N4 · Payment giả lập và Notification

**Nhánh** `feat/payment-notification` · **Review** N1 + N3.

**File giao việc**

- `services/payment/src/modules/payments/{routes,service,repository}.js`
- `services/payment/src/modules/refunds/{routes,service}.js`
- `services/payment/src/modules/webhooks/service.js`
- `services/notification/src/modules/jobs/{routes,service,repository}.js`
- `services/{payment,notification}/src/server.js`
- `contracts/openapi.{payment,notification}.json`

**API hoặc màn hình** — POST /internal/payments; POST /internal/payments/{paymentId}/simulations, /refunds; POST /internal/notifications. Mock Core webhook /internal/payment-events.

**Nghiệm thu trước khi duyệt PR** — Ngăn tạo bản ghi trùng cùng key, test success/fail/refund, gửi payload có eventId đúng. Nội bộ từ chối caller sai. Notification lưu kết quả và dựng ba mẫu verify/reset/ticket. Phương án email qua Free được chạy thử trên inbox demo; kiểm tra SMTP/Mailpit local nếu cần.

## N5 · CI, môi trường test và khung E2E

**Nhánh** `chore/ci-and-e2e` · **Review** N1 hoặc N2.

**File giao việc**

- `.github/workflows/verify.yml`
- `docker-compose.yml`
- `README.md`
- `tests/e2e/cinema.spec.js`
- `apps/web/src/api/client.js`

**API hoặc màn hình** — Kiểm tra ba /health và schema/seed; tạo khung Playwright cho năm luồng. Kiểm tra SPA do AI sinh gọi mock và Core ở các trang đã có.

**Nghiệm thu trước khi duyệt PR** — Từ clone sạch, npm ci, test backend, build frontend chạy được; DB test tách DB thật. CI có log ca lỗi và hướng dẫn chạy lại. Các file cấu hình không chứa thông tin truy cập thật; không mở mail sandbox công khai.

## Điều kiện chốt tuần

N1–N4 chạy được các API bắt buộc bằng seed. N5 chạy được quy trình test/build chung; các nhánh có thể dùng fixture để tiếp tục song song.
