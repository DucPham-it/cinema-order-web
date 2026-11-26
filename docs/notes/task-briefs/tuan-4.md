# Phiếu giao việc Tuần 4 · Kiểm thử, minh chứng và phát hành Free

**7 giờ/người · 35 giờ-người.** Các API viết tương đối với `/api/v1` trừ `/health`. Dấu ngoặc nhọn giữa tên file là các file riêng có cùng thư mục. File đã có thì sửa, file mới thì tạo khi module cần. Các file kiểm thử module ở `services/<dịch-vụ>/test/`. Giữ DB test tách môi trường cloud. Frontend do AI sinh, N5 nghiệm thu và lắp ghép.

**Phụ thuộc trong tuần** — Kiểm tra ba role của project Supabase đã chốt trước ngày deploy; chạy smoke Free trước khi quay video; khoá phạm vi mở rộng cho tới khi toàn bộ luồng bắt buộc được nghiệm thu.

## N1 · Minh chứng xác thực và phân quyền

**Nhánh** `test/auth-hardening` · **Review** N3.

**File giao việc**

- `services/api/test/auth.test.js`
- `services/api/test/authorization.test.js`
- `docs/evidence/auth.md`

**API hoặc màn hình** — Smoke /auth/login, /auth/refresh, /auth/logout, /me, /admin/users và các rule scope.

**Nghiệm thu trước khi duyệt PR** — Có bảng ca JWT hết hạn/sai, refresh dùng lại, Origin sai và rạp sai. Test chạy qua CI trên DB test. Minh chứng public không lộ cookie/token; đủ tài khoản demo theo vai trò.

## N2 · Dữ liệu, truy vấn và kiểm toán số liệu

**Nhánh** `test/catalog-reporting-evidence` · **Review** N3.

**File giao việc**

- `services/api/test/catalog.test.js`
- `services/api/test/reporting.test.js`
- `docs/evidence/data-and-perf.md`

**API hoặc màn hình** — GET /movies, /showtimes, /operations/reports/sales.

**Nghiệm thu trước khi duyệt PR** — Đối chiếu seed và dữ liệu hủy/hoàn; report đúng quyền và VND. Ghi kích thước dữ liệu, thời điểm đo, EXPLAIN ANALYZE và thời gian danh sách khi service đã ấm, mục tiêu dưới 200 ms.

## N3 · Kiểm thử giao dịch và ghế

**Nhánh** `test/booking-transaction-evidence` · **Review** N4.

**File giao việc**

- `services/api/test/booking.test.js`
- `services/api/test/tickets.test.js`
- `docs/evidence/booking.md`

**API hoặc màn hình** — POST holds/bookings/cancellations/ticket-check-ins; GET /showtimes/{showtimeId}/seats.

**Nghiệm thu trước khi duyệt PR** — Có kết quả tranh ghế, nhiều ghế rollback, hết hạn, mất ghế khi payment về muộn, cancel/check-in đua nhau và QR một lần. Đo API ghế khi ấm, mục tiêu dưới 100 ms; nếu trượt ghi kết quả và điều kiện.

## N4 · Kiểm thử và demo tích hợp liên dịch vụ

**Nhánh** `test/payment-notification-evidence` · **Review** N3.

**File giao việc**

- `services/payment/test/payment.test.js`
- `services/notification/test/jobs.test.js`
- `docs/evidence/service-integration.md`

**API hoặc màn hình** — Tạo payment, callback, refund, email verify/ticket trong môi trường demo.

**Nghiệm thu trước khi duyệt PR** — Test event trùng, chữ ký/credential sai, retry có giới hạn, lỗi gửi không làm mất trạng thái. Có minh chứng email demo nhận được và QR hợp lệ; ghi rõ phương án Free đã chạy được.

## N5 · Phát hành và gom bài nộp

**Nhánh** `chore/release-demo` · **Review** N1–N4.

**File giao việc**

- `README.md`
- `render.yaml`
- `apps/web/vercel.json`
- `.github/workflows/verify.yml`
- `docs/evidence/release.md`

**API hoặc màn hình** — Smoke ba /health, Swagger, 5 luồng đề bài, UI responsive, SSR/CSR và trailer.

**Nghiệm thu trước khi duyệt PR** — CI xanh, coverage services/api ≥60%, Lighthouse desktop ≥80 mục tiêu, có kết quả đo và bản ghi 5 luồng. Ghi URL SPA/Swagger, cách chạy Compose, repo có quyền chấm, báo cáo PDF và video ≤15 phút. Không tải video lớn vào Git.

## Điều kiện chốt tuần

Có URL triển khai và các minh chứng chấm điểm, repo có quyền xem, báo cáo PDF và video không quá 15 phút. Ghi rõ hạng mục còn thiếu nếu phụ thuộc hạ tầng Free.
