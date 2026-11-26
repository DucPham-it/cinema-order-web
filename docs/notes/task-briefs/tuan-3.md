# Phiếu giao việc Tuần 3 · Tích hợp nghiệp vụ từ đầu đến cuối

**9 giờ/người · 45 giờ-người.** Các API viết tương đối với `/api/v1` trừ `/health`. Dấu ngoặc nhọn giữa tên file là các file riêng có cùng thư mục. File đã có thì sửa, file mới thì tạo khi module cần. Các file kiểm thử module ở `services/<dịch-vụ>/test/`. Giữ DB test tách môi trường cloud. Frontend do AI sinh, N5 nghiệm thu và lắp ghép.

**Phụ thuộc trong tuần** — N1/N4 ghép xác thực email; N2/N3 thống nhất số liệu; N3/N4 ghép payment, refund và vé; N5 tích hợp các màn hình do AI sinh.

## N1 · Ghép email, session và quyền

**Nhánh** `feat/auth-integration` · **Review** N4 + N3.

**File giao việc**

- `services/api/src/modules/auth/{routes,service}.js`
- `services/api/src/modules/users/service.js`
- `services/api/src/app.js`
- `contracts/openapi.core.json`

**API hoặc màn hình** — POST /auth/register, /auth/email-verifications, /auth/login, /auth/refresh, /auth/logout; GET /me; quyền booking/operations.

**Nghiệm thu trước khi duyệt PR** — Liên kết email demo xác thực một lần; refresh cookie hoạt động qua same-origin; logout chặn phiên sau đó. Kịch bản 401/403/404 khớp quyền và phạm vi rạp. Staff/Manager không đọc dữ liệu rạp khác.

## N2 · Vận hành suất và số liệu báo cáo

**Nhánh** `feat/sales-reporting` · **Review** N3 + N5.

**File giao việc**

- `services/api/src/modules/reporting/{routes,service,repository}.js`
- `services/api/src/modules/showtimes/{routes,service}.js`
- `contracts/openapi.core.json`

**API hoặc màn hình** — GET /operations/reports/sales; PUT /operations/showtimes/{showtimeId}/status; GET /showtimes.

**Nghiệm thu trước khi duyệt PR** — Mở bán → started → completed đi đúng thứ tự. Report lọc ngày Việt Nam, rạp, phim, nhóm theo chiều đã chốt; mẫu thu 2 đơn và hoàn 1 đơn đối chiếu đúng tiền/số vé/lấp đầy. Manager bị giới hạn rạp; không đếm lặp tiền vì join ghế/combo.

## N3 · Ghép checkout, QR và soát vé

**Nhánh** `feat/checkout-integration` · **Review** N4 + N1.

**File giao việc**

- `services/api/src/modules/booking/{routes,service,repository}.js`
- `services/api/src/modules/tickets/{routes,service}.js`
- `services/api/src/app.js`
- `contracts/openapi.core.json`

**API hoặc màn hình** — POST /bookings/{bookingId}/payments, /payments/{paymentId}/simulations, /cancellations; GET /bookings/{bookingId}; POST /bookings/lookup, /ticket-check-ins; callback Core /internal/payment-events với N4.

**Nghiệm thu trước khi duyệt PR** — Đặt vé guest và customer hoàn tất với cùng giá Core; thanh toán lỗi không phát vé. Event lặp không phát lại vé. Hủy hợp lệ cập nhật đơn/ghế, hủy muộn bị từ chối; QR sai rạp hoặc bị soát lần hai bị chặn.

## N4 · Webhook có xác minh, hoàn tiền và email vé

**Nhánh** `feat/payment-email-integration` · **Review** N3 + N1.

**File giao việc**

- `services/payment/src/modules/webhooks/service.js`
- `services/payment/src/modules/refunds/service.js`
- `services/notification/src/modules/jobs/service.js`
- `services/{payment,notification}/src/server.js`
- `contracts/openapi.{payment,notification}.json`

**API hoặc màn hình** — Core gọi Payment và Notification; phiên payment gửi POST /internal/payment-events; email verify và vé QR.

**Nghiệm thu trước khi duyệt PR** — Webhook xác minh đúng body đã ký, chứng thực caller và dedup eventId; retry thử lại cùng event, tổng tiền và ID nhất quán. Thử đối soát payment/refund đến muộn; inbox demo nhận đúng người, đúng QR, không gửi hai email trong ca event lặp.

## N5 · Nghiệm thu giao diện AI và E2E

**Nhánh** `test/primary-user-journeys` · **Review** N1–N4 theo luồng.

**File giao việc**

- `apps/web/src/app/router.jsx`
- `apps/web/src/features/{auth,catalog,checkout,profile,operations}/`
- `apps/web/src/api/client.js`
- `tests/e2e/cinema.spec.js`
- `README.md`

**API hoặc màn hình** — Duyệt phim/lịch, quản trị cấu hình, đăng ký và xác thực, đặt vé tài khoản, đặt vé guest, vận hành và soát vé. Các nhóm nghiệp vụ cung cấp dữ liệu và endpoint; AI sinh UI, N5 kiểm thử.

**Nghiệm thu trước khi duyệt PR** — Playwright bao phủ 5 luồng đề bài bằng API chạy thật. UI loading/lỗi/trống hoạt động; giữ ghế lỗi 409 phản hồi được. Kiểm tra 360/768/1280 px, tải lại URL và trang chia sẻ SSR.

## Điều kiện chốt tuần

Đi từ dữ liệu seed đến đặt vé, nhận/tra cứu vé và check-in trên stack local. Cả năm luồng có E2E chạy được hoặc có issue ghi rõ blocker.
