# Phiếu giao việc Tuần 1 · Cinema Ticket Booking System

**Thời lượng 4 giờ/người, tổng 20 giờ-người.** Mốc Tuần 1 là chốt hợp đồng API, dữ liệu mẫu và môi trường để Tuần 2 triển khai song song. Trong các bảng dưới đây, “hoàn thành endpoint” nghĩa là có định nghĩa OpenAPI, ví dụ thành công/lỗi và gọi được qua mock. Các API đọc danh mục đã có trong starter cần được kiểm tra trên Core với seed. Frontend do AI sinh. N5 nghiệm thu màn hình mẫu và đường gọi API.

Các đường dẫn tính từ gốc repo, dùng `cinema-deploy-ready.zip` làm mốc. Gói này đã có CI tại `.github/workflows/verify.yml`, SQL tại `database/` và hai trang React. Các README mới nằm trong cây module của Phần 3. Giữ vị trí SQL hiện tại trong Tuần 1 để Compose tiếp tục dùng cùng bộ schema/seed. Các endpoint bên dưới viết tương đối với `/api/v1`.

## N1 · Tài khoản và phân quyền

**Nhánh** `docs/auth-contract` · **Review** N3 cho quyền sở hữu đơn, N4 cho payload email.

| File | Việc cần nộp |
|---|---|
| `services/api/src/modules/auth/README.md` — tạo | Ma trận Guest, Customer, Staff, Manager, Admin theo hành động và phạm vi. Ghi rõ Guest là ngữ cảnh truy cập, bốn vai trò còn lại là tài khoản. Mô tả vòng đời access token, refresh cookie và đăng xuất. |
| `services/api/src/modules/users/README.md` — tạo | Bảng trường được đọc/sửa trên hồ sơ và trường dành cho quản trị, như vai trò, rạp và trạng thái tài khoản. |
| `contracts/openapi.core.json` — sửa riêng Auth/Users | Chốt input, output, quyền, mã lỗi và ví dụ cho các path bên dưới. Bổ sung mẫu `401` cho login sai nếu còn thiếu và mô tả header `Set-Cookie` cho login, refresh, logout. |
| `database/seed.sql` — đối chiếu khối `users` | Xác nhận có tài khoản admin/customer và staff/manager theo rạp. Chỉ sửa phần này nếu phát hiện thiếu dữ liệu cần cho ma trận. |

**API cần xong ở mức hợp đồng/mock**

- `POST /auth/register`, `POST /auth/email-verifications`, `POST /auth/email-verification-requests`.
- `POST /auth/login`, `POST /auth/refresh`, `POST /auth/logout`.
- `POST /auth/password-reset-requests`, `POST /auth/password-resets`.
- `GET /me`, `PUT /me`, `GET /admin/users`, `PUT /admin/users/{userId}/access`.

**Nghiệm thu trước khi duyệt PR**

- [ ] Ma trận có ca Guest xem danh mục, Customer đọc đơn của mình, Staff soát vé đúng rạp, Manager bị từ chối ở rạp khác, Admin quản lý tài khoản. Ghi rõ ranh giới giữa thiếu/sai xác thực `401`, thiếu quyền `403` và trường hợp trả `404` để che sự tồn tại của đơn, thống nhất với N3.
- [ ] Contract nêu access token 15 phút, refresh được xoay vòng và thu hồi khi logout, cách xử lý token dùng lại, thuộc tính của cookie trên cloud và kiểm tra Origin ở route dùng cookie. Ví dụ response loại bỏ mật khẩu, hash và refresh token khỏi JSON.
- [ ] Chạy `npm run mock`, gọi `POST /api/v1/auth/login` và cùng URL với `?__status=401`. Kiểm tra mã HTTP, envelope và header cookie ở mẫu thành công. Có mẫu payload xác thực email/đặt lại mật khẩu đã đối chiếu với N4.

## N2 · Phim, cụm rạp, lịch chiếu và giá

**Nhánh** `feat/catalog-fixture` · **Review** N3 cho sơ đồ ghế và giá, N5 cho màn hình duyệt phim.

| File | Việc cần nộp |
|---|---|
| `services/api/src/modules/catalog/README.md` — tạo | ERD và bảng bàn giao ID phim/rạp/phòng/ghế/giá/combo. Ghi quy ước URL trailer, giá VND và cách lọc suất theo ngày/giờ Việt Nam. |
| `services/api/src/modules/showtimes/README.md` — tạo | Vòng đời `draft → on_sale → started → completed`, quy tắc trùng phòng, cách sinh kho ghế khi mở bán và quan hệ với giá. |
| `contracts/openapi.core.json` — sửa riêng Catalog và Operations Showtimes | Đối chiếu 9 API đọc đang chạy với dữ liệu thật. Chốt ví dụ ở các API quản trị liên quan đến phim, rạp, phòng, ghế, giá và combo. Chia sẻ hợp đồng `GET /showtimes/{showtimeId}/seats` với N3. |
| `database/seed.sql` — đối chiếu hoặc sửa khối danh mục/lịch chiếu | Xác nhận có một suất `on_sale` trong tương lai, ghế còn chọn được, bảng giá đúng định dạng/loại ghế và ít nhất một combo cùng rạp. Giữ ID đã được các khối booking/payment tham chiếu. |
| `services/api/src/modules/catalog/routes.js`, `services/api/src/modules/catalog/repository.js` — sửa nếu có sai lệch | Tái sử dụng API đọc đã chạy. Chỉ chỉnh chỗ lệch với contract hoặc làm hỏng luồng demo. |

**API cần xong**

- Chạy với seed local: `GET /movies`, `GET /movies/suggestions`, `GET /movies/{movieId}`, `GET /genres`, `GET /cinemas`, `GET /cinemas/{cinemaId}/combos`, `GET /showtimes`, `GET /showtimes/{showtimeId}`, `GET /showtimes/{showtimeId}/seats`.
- Chốt đặc tả/mock vận hành: `GET|POST /operations/showtimes`, `PUT|DELETE /operations/showtimes/{showtimeId}`, `PUT /operations/showtimes/{showtimeId}/status`.
- Xác nhận mẫu CRUD trong OpenAPI cho `/admin/cinemas`, `/admin/auditoriums`, `/admin/seats`, `/admin/genres`, `/admin/movies`, `/admin/price-rules`, `/admin/combos` và các path `/{id}` tương ứng. Ưu tiên cập nhật ví dụ tạo/sửa phim có `trailerUrl` nếu cần.

**Nghiệm thu trước khi duyệt PR**

- [ ] Với DB seed, từ một phim lấy được suất `on_sale`, đúng phòng/rạp, danh sách ghế có giá và combo cùng rạp. Ghi lại ID tìm được và các lệnh gọi trong PR để N3 chạy lại.
- [ ] Ví dụ phim có URL trailer hợp lệ về định dạng, và phim không có trailer trả `trailerUrl: null`. Mẫu POST/PUT và cách xóa trailer khớp hợp đồng hiện tại.
- [ ] README nêu rõ giờ lọc suất theo `Asia/Ho_Chi_Minh`, mã lỗi khi lịch chồng lấn và cách phản ánh trạng thái ghế. Kèm một response suất mở bán và một response ghế làm bằng chứng.

## N3 · Giữ ghế, đơn đặt vé và soát vé

**Nhánh** `docs/booking-contract` · **Review** N2 cho tồn ghế, N4 cho trạng thái thanh toán, N1 cho quyền.

| File | Việc cần nộp |
|---|---|
| `services/api/src/modules/booking/README.md` — tạo | Sơ đồ quan hệ giữa kho ghế, phiên giữ và đơn. Bảng trạng thái, quyền khách đăng nhập/khách vãng lai, quy tắc giữ hết hạn và hủy theo mốc ghi trong thiết kế. Nêu trường dữ liệu chốt giá và nhóm thao tác cùng transaction. |
| `services/api/src/modules/tickets/README.md` — tạo | Điều kiện phát hành vé, quan hệ đơn–ghế–vé, ca QR hợp lệ, đã dùng, vô hiệu hoặc sai rạp. |
| `contracts/openapi.core.json` — sửa riêng Booking/Tickets | Hoàn thiện request/response và status cho các path bên dưới. Ghi cách dùng `Idempotency-Key`, `X-Hold-Token`, `X-Booking-Code` theo route và quyền. Đối chiếu đầu vào chọn ghế với N2. |
| `database/001_init_schema.sql`, `database/seed.sql` — đối chiếu | Kiểm tra ràng buộc khóa ghép suất/ghế và mẫu đơn/vé. Nếu cần chỉnh schema hoặc seed để chốt hợp đồng, phối hợp N2 và N5 trước khi sửa phần liên quan. |

**API cần xong ở mức hợp đồng/mock**

- `POST /showtimes/{showtimeId}/holds`, `DELETE /holds/{holdId}`.
- `POST /bookings`, `POST /bookings/lookup`, `GET /me/bookings`, `GET /bookings/{bookingId}`.
- `POST /bookings/{bookingId}/payments`, `POST /bookings/{bookingId}/payments/{paymentId}/simulations`, `POST /bookings/{bookingId}/cancellations`.
- `POST /ticket-check-ins`, `GET /operations/showtimes/{showtimeId}/attendees`, `GET /operations/bookings`, `GET /operations/bookings/{bookingId}`.

**Nghiệm thu trước khi duyệt PR**

- [ ] Có bộ ví dụ nối từ ghế của suất mẫu qua hold, booking, payment và ticket. Ví dụ giá là giá chốt phía Core. Đối chiếu cả khách đăng nhập và guest, gồm cách chứng minh quyền trên hold/booking.
- [ ] Mô tả bốn tình huống bắt buộc: hai yêu cầu tranh một ghế thì chỉ một thành công và yêu cầu còn lại `409`; hold hết hạn thì giải phóng; thanh toán đến muộn sau khi mất ghế thì đưa vào xử lý hoàn tiền và không phát vé; QR hợp lệ chỉ được soát một lần.
- [ ] Mock giữ ghế trả `201` và với `?__status=409` trả lỗi đặc tả. PR kèm thêm ví dụ lỗi tra cứu hoặc soát vé. Ghi rõ các ca đồng thời và vòng đời thật cần test tích hợp khi module được triển khai.

## N4 · Hợp đồng Payment, webhook và Notification

**Nhánh** `docs/internal-service-contracts` · **Review** N3 cho payment/refund, N1 cho email xác thực.

| File | Việc cần nộp |
|---|---|
| `contracts/openapi.payment.json` — sửa | Chốt tạo giao dịch, kết quả giả lập, hoàn tiền; khai báo `Idempotency-Key` ở các thao tác theo hợp đồng, mã trạng thái và ví dụ. |
| `contracts/openapi.notification.json` — sửa | Chốt enqueue và payload cho `verify_email`, `reset_password` và `ticket_issued` dùng email/QR fixture. |
| `contracts/openapi.core.json` — sửa riêng `POST /internal/payment-events` | Đặc tả event và header chữ ký/timestamp, phạm vi xác thực máy với máy và phản hồi khi đã xử lý event. |
| `services/payment/src/modules/webhooks/README.md` — tạo | Bảng `bookingId/bookingRef → paymentId → eventId`, trạng thái, cách gửi lại và quy tắc xử lý event trùng. |
| `services/notification/src/modules/jobs/README.md` — tạo | Mapping template với dữ liệu bắt buộc, khóa chống enqueue trùng và mẫu email để N1/N3 review. |

**API cần xong ở mức hợp đồng/mock**

- **Payment** — `POST /internal/payments`, `POST /internal/payments/{paymentId}/simulations`, `POST /internal/payments/{paymentId}/refunds`.
- **Core** — `POST /internal/payment-events`.
- **Notification** — `POST /internal/notifications`.

**Nghiệm thu trước khi duyệt PR**

- [ ] Ví dụ dùng cùng mã đơn và mã payment qua các dịch vụ, thống nhất `amountVnd` và `currency: "VND"`. Có cả `payment.succeeded`, `payment.failed`, `refund.succeeded`, `refund.failed`, kèm điều kiện mỗi event làm thay đổi trạng thái.
- [ ] Phân biệt ý nghĩa của `Idempotency-Key` khi tạo giao dịch/hoàn tiền/enqueue và `eventId` khi nhận webhook. Ghi rõ cùng khóa, cùng payload nhận lại kết quả trước; phát lại webhook không tạo thêm vé hay thông báo. Có mô tả header nội bộ, chữ ký trên raw body và thời hạn request theo thiết kế.
- [ ] Gọi mock tạo payment tại cổng `4011`, webhook tại `4010` và enqueue email tại `4012`; phản hồi mẫu lần lượt `201`, `200`, `200`; Notification trả `202` khi cùng khóa đang xử lý. Bằng chứng PR đính kèm payload thử bằng dữ liệu giả. Gửi email thật và xác minh webhook bằng code thuộc mốc triển khai tiếp theo.

## N5 · Nền tảng repo, mock, CI và nghiệm thu UI sinh bởi AI

**Nhánh** `chore/week-1-integration` · **Review** một thành viên khác kiểm tra quy trình chạy từ bản clone sạch.

| File | Việc cần nộp |
|---|---|
| `README.md`, `.env.example`, `apps/web/.env.example` — cập nhật khi cần | Hướng dẫn hai chế độ mock và DB local. Gắn tài liệu nền, URL/cổng mẫu và lệnh chuyển frontend sang mock. Tách cấu hình trình duyệt khỏi cấu hình backend. |
| `docker-compose.yml`, `database/001_init_schema.sql`, `database/seed.sql` — xác nhận lắp ghép | Giữ Compose local chỉ chạy PostgreSQL. Kiểm tra thứ tự nạp hai SQL trên volume mới và chỉ điều chỉnh phần cấu hình lắp ghép. |
| `scripts/mock.mjs`, `.github/workflows/verify.yml` — cập nhật khi cần | Dùng lại mock đọc ba OpenAPI và CI hiện hữu. Đảm bảo các lệnh ở README thực hiện được. N5 kiểm tra JSON, mẫu phản hồi và smoke qua mock sau khi ghép PR của N1–N4. |
| `apps/web/src/app/router.jsx`, `apps/web/src/features/catalog/pages.jsx`, `apps/web/src/api/client.js` — kiểm tra, sửa khi tích hợp cần | Dùng hai trang đã có và Axios. N5 chỉ kết nối, kiểm tra và sửa lỗi lắp ghép ở mã do AI tạo. |
| `apps/web/vercel.json`, `render.yaml` — đối chiếu | Xác nhận đặt đúng chỗ, hướng dẫn biến placeholder phù hợp với README. Mốc này kiểm tra cấu hình và build, việc phát hành cloud ở mốc sau. |

**Màn hình và API cần xong**

- **Danh sách/tìm phim** `/` gọi `GET /movies`, hiển thị kết quả, trạng thái trống và lỗi. **Chi tiết phim** `/movies/:movieId` gọi `GET /movies/{movieId}` và `GET /showtimes?movieId=…`; thử mở URL trực tiếp và hiển thị nút trailer khi có URL. Mock hiện trả fixture tĩnh. Dùng Core + seed để kiểm tra thật việc tìm/lọc.
- **Khung gọi API** — Mock Core `4010`, Payment `4011`, Notification `4012`; chạy thử `GET /health` từ các dịch vụ local khi Postgres đã sẵn sàng. Đăng nhập, checkout, quản trị và soát vé có contract cho AI ở tuần này.

**Nghiệm thu trước khi duyệt PR**

- [ ] Từ clone sạch, hướng dẫn chạy được `npm run mock` và `docker compose up -d --wait` ở hai chế độ. Chế độ Compose dùng URL PostgreSQL localhost, tạo đủ ba schema và nạp được suất mẫu. Kiểm tra ba `/health` trả `200` khi chạy ba tiến trình Express local.
- [ ] CI chạy cài từ lockfile, `npm test` và build Vite. PR có link job. Có bản ghi smoke cho API phim, giữ ghế lỗi `409`, tạo payment và enqueue notification. Xác nhận mock đang phục vụ example của OpenAPI.
- [ ] Có ảnh hoặc clip ngắn của hai màn hình và bước reload URL chi tiết. Kiểm tra trạng thái lỗi và trống bằng mock/fixture hoặc dữ liệu local. Rà biến môi trường, giữ bí mật DB và khóa nội bộ ở backend.

## Ghép PR trong Tuần 1

1. **Giờ đầu** — N5 xác nhận repo nền, vị trí file và lệnh chạy. N2 chốt suất/ghế mẫu, N1 và N3 thống nhất quyền sở hữu. N3 và N4 thống nhất ID, số tiền, mã trạng thái và header.
2. **Làm song song** — Mỗi người làm trên nhánh riêng. Khi sửa chung `contracts/openapi.core.json`, chỉ thay operation thuộc mình theo phiếu; N3 sở hữu path booking bên browser, N4 sở hữu webhook nội bộ, N2 sở hữu `GET /showtimes/{showtimeId}/seats` với N3 review. Giữ format JSON để diff dễ đọc.
3. **Duyệt và bàn giao** — PR ghi file, endpoint, ví dụ và kết quả nghiệm thu. Sau khi merge từng PR, cập nhật nhánh tiếp theo theo `main` nếu chạm cùng file. N5 smoke lại ba mock và hai màn hình trên bản đã ghép trước khi chốt Tuần 1.
