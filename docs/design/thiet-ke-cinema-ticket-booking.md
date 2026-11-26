# Thiết kế đồ án Cinema Ticket Booking System

## 1. Bảng phân công công việc (Task Allocation)

Hệ thống dùng một React SPA và ba dịch vụ Express: `core`, `payment` và `notification`. Core quản lý người dùng, danh mục, lịch chiếu, ghế, đặt vé và soát vé. Payment mô phỏng giao dịch. Notification phát email xác thực và vé điện tử. Mỗi dịch vụ sở hữu dữ liệu trong schema riêng và trao đổi dữ liệu qua API. Nhóm đã chốt một project Supabase Free với ba schema/role runtime riêng. Bản cloud dùng Vercel cho SPA, Render cho ba API Express và Supabase cho PostgreSQL. Frontend do AI tạo, dùng OpenAPI và mock. N5 phụ trách nghiệm thu và tích hợp bản sinh ra.

| Giai đoạn | Module/Tính năng | Chi tiết công việc | Người phụ trách | Đầu ra kỳ vọng (Deliverable) |
|---|---|---|---|---|
| Tuần 1 · 4 giờ/người | Tài khoản và quyền | Chốt 5 vai trò, phạm vi cụm rạp, JWT, refresh và quyền sở hữu đơn | N1 | Ma trận quyền, hợp đồng Auth |
| Tuần 1 · 4 giờ/người | Danh mục và lịch chiếu | Chốt rạp, phòng, ghế, lịch, giá, combo và trường trailer của phim | N2 | ERD module, dữ liệu 1 suất chiếu mở bán |
| Tuần 1 · 4 giờ/người | Đặt vé và soát vé | Chốt vòng đời giữ ghế, đặt vé, hủy, QR và invariant tranh chấp ghế | N3 | ERD giao dịch, hợp đồng Booking |
| Tuần 1 · 4 giờ/người | Giao tiếp liên dịch vụ | Chốt payment attempt, event, lặp lại, refund và email | N4 | Hợp đồng API nội bộ, payload mẫu |
| Tuần 1 · 4 giờ/người | Setup repo | Tạo workspace, Compose, CI, OpenAPI và mock để AI bắt đầu dựng SPA | N5 | Repo khởi tạo, mock có thể gọi ngay |
| Tuần 2 · 12 giờ/người | Auth & users | Đăng ký, email verify, đăng nhập, JWT, rotate refresh, hồ sơ, quản lý vai trò | N1 | Module chạy được, seed tài khoản, test quyền |
| Tuần 2 · 12 giờ/người | Catalog & showtimes | CRUD, sơ đồ ghế, giá/combo, autocomplete, lọc lịch và vòng đời suất; nhập và kiểm tra link trailer | N2 | Seed rạp/phòng/phim/suất, test lịch trùng và bộ lọc |
| Tuần 2 · 12 giờ/người | Booking & ticket | Trạng thái ghế, giữ ghế, tạo đơn, guest lookup, lịch sử, hủy và check-in | N3 | Test giao dịch, tranh ghế, hết hạn và check-in lặp |
| Tuần 2 · 12 giờ/người | Payment & notification | Payment giả lập, webhook ký HMAC, SMTP/Mailpit, QR email, xử lý lặp | N4 | Hai API Express độc lập, test hợp đồng và xác minh webhook |
| Tuần 2 · 12 giờ/người | CI và kiểm thử tích hợp | Docker Compose, CI, health checks, request ID, khung Playwright | N5 | Môi trường test tái lập và kiểm tra PR tự động |
| Tuần 3 · 9 giờ/người | Tích hợp quyền và email | Ghép N1 với email N4, phạm vi rạp N2 và quyền sở hữu vé N3 | N1 | E2E đăng ký/xác thực, kiểm thử quyền theo rạp |
| Tuần 3 · 9 giờ/người | Báo cáo và vận hành | Ghép số liệu đơn/vé N3, kiểm tra mở bán, bắt đầu, kết thúc suất | N2 | Dashboard có số liệu đối chiếu với dữ liệu đơn và vé |
| Tuần 3 · 9 giờ/người | Booking → QR | Ghép giữ ghế, báo giá, payment, phát hành vé và quét QR | N3 | E2E hai kiểu khách, test giao dịch và hủy |
| Tuần 3 · 9 giờ/người | Thanh toán và gửi vé | Ghép webhook, email xác thực/vé, refund, thử lỗi và retry | N4 | Mailpit có email đúng, event trùng xử lý một lần |
| Tuần 3 · 9 giờ/người | Nghiệm thu SPA | Ghép bản AI với API, kiểm thử 5 luồng, responsive, router, form, trailer và trang chia sẻ SSR | N5 | Playwright trên stack tích hợp, danh sách lỗi có người xử lý |
| Tuần 4 · 7 giờ/người | Bảo mật và tài liệu | Chạy test JWT, cookie, quyền sở hữu và phạm vi; viết phần Auth | N1 | Bảng minh chứng bảo mật và mô tả phân quyền |
| Tuần 4 · 7 giờ/người | Truy vấn và tài liệu | Tối ưu index, đo danh sách và đối chiếu số liệu báo cáo | N2 | Kế hoạch truy vấn, ERD và số đo danh sách |
| Tuần 4 · 7 giờ/người | Kiểm thử giao dịch | Đo API ghế, chạy ca xung đột/hết hạn/thanh toán đến muộn | N3 | Minh chứng giao dịch đúng và số đo trạng thái ghế |
| Tuần 4 · 7 giờ/người | Kiểm thử liên dịch vụ | Kiểm chứng xác thực, replay, retry, mất kết nối và cấu hình mail demo | N4 | Minh chứng payment/email, log có request ID |
| Tuần 4 · 7 giờ/người | Triển khai và nộp | Vercel, ba dịch vụ Render, PostgreSQL Supabase, Swagger UI, coverage, Lighthouse, PDF và video báo cáo | N5 + cả nhóm review | URL SPA/Swagger, PDF, video tối đa 15 phút, repo có quyền chấm |

Mỗi người 32 giờ, tổng **160 giờ-người**. Chốt hợp đồng và seed trong tuần 1. Tuần 2 cả 5 người có thể làm song song với fixture. Khi N2 bàn giao suất chiếu mẫu và N4 bàn giao thanh toán thành công giả lập, N3 ghép ngay đường găng **suất mở bán → giữ ghế → đặt vé → thanh toán → vé QR → soát vé**.

Điều kiện nộp gồm 5 luồng đề bài, ít nhất 2 ca unit mỗi module, Vitest + Supertest cho các API chính, tối thiểu hai component được kiểm thử bằng React Testing Library, Playwright trên Compose và coverage `services/api` ≥ 60%. Kiểm tra màn hình 360/768/1280 px, mục tiêu API danh sách < 200 ms, API ghế < 100 ms và Lighthouse desktop ≥ 80. Nhóm đính kèm số liệu CSR/SSR cho trang chia sẻ, `EXPLAIN ANALYZE` và minh chứng bảo mật. WebSocket, Google Login và thanh toán thật đứng sau phạm vi bắt buộc.

## 2. Thiết kế Database & Danh sách API Endpoints (API Contract)

### Mô hình nội dung và nghiệp vụ

| Cụm nội dung | Thành phần và quan hệ | Cách sử dụng |
|---|---|---|
| Danh mục công khai | Phim ↔ thể loại, rạp → phòng → sơ đồ ghế, phim + phòng → suất chiếu | Trang tìm kiếm, chi tiết phim có trailer, danh sách lịch chiếu và trang chia sẻ SSR |
| Giá và hàng bán kèm | Quy tắc giá theo rạp/định dạng/loại ghế, combo thuộc rạp | Core tính giá, lưu ảnh chụp giá ở đơn và dòng đơn |
| Kho ghế theo suất | Một ghế vật lý sinh một vị trí bán cho mỗi suất | Sơ đồ ghế dùng dữ liệu phòng; trạng thái bán đọc từ Core theo suất và có thể polling |
| Giao dịch | Phiên giữ → đơn → lần thanh toán → vé QR theo từng ghế | Khách đăng nhập dùng JWT; khách vãng lai tra cứu bằng mã đặt chỗ có entropy cao |
| Vận hành | Nhân viên quét vé, quản lý mở/đóng suất của rạp mình, admin toàn hệ thống | Soát vé một lần, thống kê doanh thu, số vé và tỷ lệ lấp đầy |
| Tài khoản và liên lạc | Khách xác thực email; khách đăng nhập xem lịch sử; notification phát email | Token xác thực và refresh lưu dạng hash; email ghi vào outbox rồi gửi bất đồng bộ |

### Trailer trên trang chi tiết phim

N2 lưu một URL trailer tùy chọn trong `movies.trailer_url`. Admin nhập link khi tạo hoặc sửa phim. API dùng `trailerUrl`: khi POST bỏ trống thì lưu `null`, khi PUT gửi `null` để xóa, nếu PUT thiếu trường thì giữ link hiện tại. Phản hồi chi tiết phim có `trailerUrl` là URL hợp lệ hoặc `null`. URL mock chỉ là fixture minh họa, thay bằng trailer chính thức hoặc video nhóm được phép dùng khi seed dữ liệu demo.

Starter thống nhất URL YouTube dạng `https://www.youtube.com/watch?v=<videoId>`. Backend chuẩn hóa link hợp lệ về dạng này trước khi lưu; frontend tách ID, tạo URL embed từ hostname cố định của nhà cung cấp, chỉ tải trình phát khi người dùng bấm **Xem trailer**, giữ khung 16:9 và hiển thị liên kết mở trên YouTube nếu video không cho nhúng. Phim có `null` thì ẩn nút. N5 kiểm tra cả hai trường hợp và smartphone trước khi quay video báo cáo.

### Database schema đề xuất

PostgreSQL 17 và Knex 3. Dùng UUID cho ID, `timestamptz` cho thời gian, số nguyên VND cho tiền. Tên bảng/cột tiếng Anh `snake_case`. API trả thời gian ISO 8601 UTC, UI định dạng `Asia/Ho_Chi_Minh` và VND. PK mặc định là `id` trừ bảng nối và các khóa ghép được ghi rõ.

| CSDL | Bảng | Trường chính và quan hệ |
|---|---|---|
| Core | `users` | id, email UNIQUE, password_hash, full_name, phone, role, cinema_id FK nullable, email_verified_at, disabled_at. Staff/manager phải có rạp. |
| Core | `refresh_sessions` | id, user_id FK, family_id, token_hash UNIQUE, expires_at, used_at, revoked_at; giữ phiên cũ để phát hiện dùng lại. |
| Core | `email_tokens` | id, user_id FK, purpose, token_hash UNIQUE, expires_at, used_at; dùng cho xác thực và đặt lại mật khẩu. |
| Core | `cinemas`, `auditoriums` | Rạp có name, address, status. Phòng có cinema_id FK, name, status; UNIQUE(cinema_id, name). |
| Core | `seats` | auditorium_id FK, row_label, seat_number, kind, x, y, is_active; UNIQUE(auditorium_id, row_label, seat_number). Ghế đôi là một vị trí bán có số người phục vụ xác định. |
| Core | `movies`, `genres`, `movie_genres` | Phim có title, slug UNIQUE, synopsis, poster_url, trailer_url nullable, duration_minutes, age_rating, release_date, status. Khóa ghép movie_id/genre_id ở bảng nối. |
| Core | `showtimes` | movie_id, auditorium_id, format, starts_at, ends_at, status. Ràng buộc khoảng thời gian suất hoạt động cùng phòng không chồng lấn, kể cả tạo song song. |
| Core | `price_rules`, `combos` | Giá có cinema_id, format, seat_kind, amount_vnd, active. Quy tắc đang hoạt động duy nhất theo bộ khóa giá. Combo có cinema_id, name, price_vnd, active. |
| Core | `showtime_seats` | PK(showtime_id, seat_id), status, hold_id nullable, hold_expires_at, booking_id nullable. Tạo hàng tồn ghế lúc mở bán; ghế phải thuộc phòng của suất. |
| Core | `seat_holds` | showtime_id FK, customer_id nullable, guest_secret_hash nullable, expires_at, status; chỉ chủ phiên giữ mới tạo được đơn. |
| Core | `bookings` | showtime_id FK, hold_id FK UNIQUE, user_id nullable, booking_code_hash UNIQUE, contact_name/email/phone, status, total_vnd, expires_at, confirmed_at, cancelled_at. |
| Core | `booking_seats`, `booking_combos` | Khóa ghép theo booking_id và seat_id/combo_id. Lưu nhãn, loại ghế/giá, tên combo/đơn giá và số lượng tại thời điểm đặt. |
| Core | `payment_attempts`, `processed_payment_events`, `outbox_events` | Lần thanh toán gắn booking_id và external_payment_id UNIQUE, amount_vnd, status. Event id UNIQUE chống xử lý lặp. Outbox có kind, payload, status, next_attempt_at. |
| Core | `tickets`, `ticket_check_ins` | Vé gắn booking_id/seat_id, qr_token_hash UNIQUE, status. Soát vé có ticket_id UNIQUE, staff_id, checked_in_at. |
| Payment | `payments`, `refunds`, `webhook_deliveries` | Payments có booking_ref, amount_vnd, currency, status, idempotency_key UNIQUE. Refund thuộc payment, key UNIQUE. Delivery có event_id UNIQUE, body và lịch retry. |
| Notification | `notification_jobs` | idempotency_key UNIQUE, template, recipient, data, status, attempts, next_attempt_at, created_at, sent_at, provider_message_id; hạn chế lưu và ghi log dữ liệu cá nhân. |

Khóa ngoại chỉ dùng trong từng schema dịch vụ. Các dịch vụ dùng ID ngoài làm tham chiếu qua hợp đồng API. Index ưu tiên `showtimes(movie_id, starts_at)`, `showtimes(auditorium_id, starts_at)`, `bookings(user_id, created_at)`, `bookings(showtime_id, status)` và trạng thái/expiry ở kho ghế. Index tìm kiếm phim theo truy vấn đo được. Dùng ràng buộc khoảng thời gian hoặc serialize theo phòng trong giao dịch để chống lịch trùng.

**Quy tắc đề xuất cần nhóm duyệt trong tuần 1**

- Giữ ghế **5 phút**, hủy vé chưa sử dụng tối thiểu **120 phút** trước suất. Cả hai là thông số demo. Suất chạy `draft → on_sale → started → completed`. Vé chạy `valid → checked_in` hoặc `valid → void`.
- Giữ ghế theo giao dịch. Khóa các hàng `showtime_seats` theo thứ tự cố định, xét hết hạn bằng đồng hồ server và giữ toàn bộ danh sách hoặc trả `409`. Job dọn và API lấy ghế cùng dùng quy tắc hết hạn. Hàng của ghế đã thanh toán chỉ được giải phóng sau khi hủy hợp lệ.
- Core chốt giá và hạn thanh toán khi tạo đơn. Cổng thanh toán nhận tiền chốt từ Core. Webhook giao dịch thành công chỉ xác nhận đơn khi đơn còn hiệu lực và vẫn giữ đủ ghế. Nếu tiền đến sau khi ghế hết hạn/đã được cấp lại, ghi nhận kết quả và đưa yêu cầu hoàn tiền vào outbox; ghế và vé của khách khác giữ nguyên. Ghi kết quả xử lý sự kiện, cập nhật vé và tạo outbox trong cùng giao dịch.
- Soát vé kiểm tra rạp và trạng thái suất theo chính sách đề xuất `on_sale` hoặc `started`. Khóa vé khi hủy hoặc soát. Hủy đơn đã xác nhận chuyển sang `cancellation_pending`, vô hiệu hóa vé và xếp hàng hoàn tiền giả lập. Sau khi hoàn tất, chuyển `cancelled` và trả ghế. Refund lỗi được retry để tránh lệch số liệu.
- Doanh thu là tiền thu trừ tiền đã hoàn trong phạm vi báo cáo. Số vé và tỷ lệ lấp đầy dùng vé còn hiệu lực/đã soát trên kho ghế mở bán. Lọc theo thời gian suất chiếu và quy đổi ngày từ giờ Việt Nam sang khoảng UTC. Ghế đôi đếm là một vị trí bán cho tử số và mẫu số.

### Quy ước hợp đồng API

Các path công khai và quản trị được gọi trên Core. Payment và Notification có base URL riêng. Các ID ngắn trong ví dụ giúp đọc dễ hơn. Domain thật dùng UUID. `Public` gồm khách vãng lai. `User` là người đăng nhập. `Manager@rạp`, `Staff@rạp` chỉ truy cập tài nguyên thuộc phạm vi được gán. `Admin` toàn hệ thống. `Service` yêu cầu xác thực máy với máy. Admin có các quyền nghiệp vụ nội bộ trong phạm vi toàn hệ thống. Khách đăng nhập chỉ đọc hoặc thao tác trên đơn của mình.

Danh sách mặc định `page=1&pageSize=20`, tối đa 100. Tham số ngày dùng `YYYY-MM-DD` theo giờ Việt Nam. Các API đặt vé, thanh toán và hủy có thể được gọi lại với `Idempotency-Key`; key phải gắn với tác nhân, thao tác và hash request. Cùng key và nội dung trả kết quả cũ, thay đổi nội dung trả `409`.

Cột mẫu JSON trình bày phần `data`. Mã HTTP tương ứng được ghi cùng mẫu; lỗi dùng envelope ở phần 3. `openapi.*.json` có các ví dụ đầy đủ để nhập vào công cụ mock. Mẫu mô phỏng nhất quán cho một suất chiếu; mã định danh và thông tin xác thực chỉ dùng cho fixture.


#### Xác thực và tài khoản

| Method | Endpoint | Mô tả | Request Body / Params | Response mẫu (JSON) | Phân quyền |
|---|---|---|---|---|---|
| POST | `/api/v1/auth/register` | Đăng ký | `{"email":"linh@example.test","password":"demo-pass-123","fullName":"Nguyễn Linh"}` | 202 `{"accepted":true}` | Public |
| POST | `/api/v1/auth/email-verifications` | Xác thực email | `{"token":"email_demo_token"}` | 200 `{"verified":true}` | Public |
| POST | `/api/v1/auth/email-verification-requests` | Yêu cầu gửi lại email xác thực | `{"email":"linh@example.test"}` | 202 `{"accepted":true}` | Public |
| POST | `/api/v1/auth/password-reset-requests` | Yêu cầu đặt lại mật khẩu | `{"email":"linh@example.test"}` | 202 `{"accepted":true}` | Public |
| POST | `/api/v1/auth/password-resets` | Đổi mật khẩu bằng token một lần | `{"token":"reset_demo_token","newPassword":"demo-pass-456"}` | 200 `{"updated":true}` | Public |
| POST | `/api/v1/auth/login` | Đăng nhập và set cookie refresh | `{"email":"linh@example.test","password":"demo-pass-123"}` | 200 `{"accessToken":"mock_access_token","expiresIn":900,"user":{"id":"u1","role":"customer"}}` | Public |
| POST | `/api/v1/auth/refresh` | Xoay cookie refresh | `cookie refresh_token, header Origin` | 200 `{"accessToken":"mock_access_token_2","expiresIn":900}` | Refresh cookie |
| POST | `/api/v1/auth/logout` | Thu hồi phiên và xóa cookie | `cookie refresh_token, header Origin` | 200 `{"loggedOut":true}` | Refresh cookie |
| GET | `/api/v1/me` | Đọc hồ sơ | `—` | 200 `{"id":"u1","fullName":"Nguyễn Linh","email":"linh@example.test","role":"customer"}` | User |
| PUT | `/api/v1/me` | Cập nhật hồ sơ | `{"fullName":"Nguyễn Linh","phone":"0900000000"}` | 200 `{"id":"u1","fullName":"Nguyễn Linh","phone":"0900000000"}` | User |
| GET | `/api/v1/admin/users` | Danh sách tài khoản | `?role=staff&cinemaId=c1&page=1` | 200 `{"items":[{"id":"u2","role":"staff","cinemaId":"c1","disabled":false}],"pagination":{"page":1,"pageSize":20,"total":1}}` | Admin |
| PUT | `/api/v1/admin/users/{userId}/access` | Thay quyền và phạm vi rạp | `{"role":"staff","cinemaId":"c1","disabled":false}` | 200 `{"id":"u2","role":"staff","cinemaId":"c1","disabled":false}` | Admin |

#### Danh mục và lịch chiếu công khai

| Method | Endpoint | Mô tả | Request Body / Params | Response mẫu (JSON) | Phân quyền |
|---|---|---|---|---|---|
| GET | `/api/v1/movies` | Tìm kiếm, lọc và phân trang phim | `?q=mat&genreId=g1&status=now_showing&page=1&pageSize=20` | 200 `{"items":[{"id":"m1","title":"Mặt Trời"}],"pagination":{"page":1,"pageSize":20,"total":1}}` | Public |
| GET | `/api/v1/movies/suggestions` | Autocomplete tên phim | `?q=mat&pageSize=5` | 200 `{"items":[{"id":"m1","title":"Mặt Trời"}]}` | Public |
| GET | `/api/v1/movies/{movieId}` | Chi tiết phim và link trailer | `movieId` | 200 `{"id":"m1","title":"Mặt Trời","durationMinutes":100,"genreIds":["g1"],"posterUrl":"https://example.test/poster.jpg","trailerUrl":"https://www.youtube.com/watch?v=DEMO_VIDEO1"}` | Public |
| GET | `/api/v1/genres` | Thể loại để lọc | `?page=1` | 200 `{"items":[{"id":"g1","name":"Phiêu lưu"}],"pagination":{"page":1,"pageSize":20,"total":1}}` | Public |
| GET | `/api/v1/cinemas` | Danh sách cụm rạp | `?page=1` | 200 `{"items":[{"id":"c1","name":"Cinema Quận 1"}],"pagination":{"page":1,"pageSize":20,"total":1}}` | Public |
| GET | `/api/v1/showtimes` | Lọc suất mở bán theo phim, rạp, ngày, định dạng và giờ | `?movieId=m1&cinemaId=c1&date=2026-12-20&format=2D&fromTime=18:00&toTime=22:00&page=1` | 200 `{"items":[{"id":"st1","cinemaId":"c1","startsAt":"2026-12-20T12:30:00Z","format":"2D","status":"on_sale"}],"pagination":{"page":1,"pageSize":20,"total":1}}` | Public |
| GET | `/api/v1/showtimes/{showtimeId}` | Thông tin suất | `showtimeId` | 200 `{"id":"st1","movieId":"m1","cinemaId":"c1","auditoriumId":"a1","startsAt":"2026-12-20T12:30:00Z","format":"2D","status":"on_sale"}` | Public |
| GET | `/api/v1/showtimes/{showtimeId}/seats` | Sơ đồ và trạng thái ghế để polling | `showtimeId` | 200 `{"showtimeId":"st1","seats":[{"id":"s1","label":"A1","kind":"standard","status":"available","x":1,"y":1,"priceVnd":95000}]}` | Public |
| GET | `/api/v1/cinemas/{cinemaId}/combos` | Combo được bán tại rạp | `?page=1` | 200 `{"items":[{"id":"co1","name":"Combo Bắp Nước","priceVnd":65000}],"pagination":{"page":1,"pageSize":20,"total":1}}` | Public |

#### Đặt vé và soát vé

| Method | Endpoint | Mô tả | Request Body / Params | Response mẫu (JSON) | Phân quyền |
|---|---|---|---|---|---|
| POST | `/api/v1/showtimes/{showtimeId}/holds` | Giữ ghế và cấp holdToken cho guest | `{"seatIds":["s1"]}` | 201 `{"id":"h1","expiresAt":"2026-12-20T11:05:00Z","holdToken":"mock_guest_hold_token"}` | Public / User |
| DELETE | `/api/v1/holds/{holdId}` | Giải phóng phiên giữ chưa tạo đơn | `holdId, guest gửi X-Hold-Token` | 200 `{"id":"h1","status":"released"}` | Chủ phiên giữ |
| POST | `/api/v1/bookings` | Tạo đơn và chốt giá | `{"holdId":"h1","combos":[{"comboId":"co1","quantity":1}],"contact":{"name":"Nguyễn Linh","email":"linh@example.test","phone":"0900000000"}} · Idempotency-Key, guest gửi X-Hold-Token` | 201 `{"id":"b1","bookingCode":"DEMO-GUEST-CODE","status":"pending_payment","totalVnd":160000,"expiresAt":"2026-12-20T11:05:00Z"}` | Chủ phiên giữ |
| POST | `/api/v1/bookings/lookup` | Tra cứu guest bằng mã trong body | `{"bookingCode":"DEMO-GUEST-CODE"}` | 200 `{"id":"b1","status":"confirmed","showtimeId":"st1","totalVnd":160000,"seats":["A1"]}` | Public + mã guest |
| GET | `/api/v1/me/bookings` | Lịch sử vé của tài khoản | `?page=1` | 200 `{"items":[{"id":"b1","status":"confirmed","totalVnd":160000}],"pagination":{"page":1,"pageSize":20,"total":1}}` | User |
| GET | `/api/v1/bookings/{bookingId}` | Chi tiết đơn của chính chủ | `bookingId` | 200 `{"id":"b1","showtimeId":"st1","status":"confirmed","totalVnd":160000,"tickets":[{"id":"t1","seatLabel":"A1","status":"valid"}]}` | Chủ đơn đăng nhập |
| POST | `/api/v1/bookings/{bookingId}/payments` | Khởi tạo một lần thanh toán | `bookingId, Idempotency-Key, guest gửi X-Booking-Code` | 201 `{"paymentId":"p1","status":"pending","checkoutPath":"/api/v1/bookings/b1/payments/p1/simulations"}` | Chủ đơn |
| POST | `/api/v1/bookings/{bookingId}/payments/{paymentId}/simulations` | Mô phỏng thao tác cổng thanh toán | `{"outcome":"succeeded"} · guest gửi X-Booking-Code` | 202 `{"paymentId":"p1","status":"processing"}` | Chủ đơn · môi trường demo |
| POST | `/api/v1/bookings/{bookingId}/cancellations` | Hủy đơn theo chính sách | `bookingId, Idempotency-Key, guest gửi X-Booking-Code` | 202 `{"id":"b1","status":"cancellation_pending"}` | Chủ đơn |
| POST | `/api/v1/ticket-check-ins` | Soát vé QR tại rạp | `{"qrToken":"mock_ticket_qr_token"}` | 201 `{"ticketId":"t1","seatLabel":"A1","checkedInAt":"2026-12-20T12:15:00Z"}` | Staff@rạp / Manager@rạp / Admin |
| GET | `/api/v1/operations/showtimes/{showtimeId}/attendees` | Danh sách khách và trạng thái soát | `?page=1` | 200 `{"items":[{"ticketId":"t1","seatLabel":"A1","status":"checked_in"}],"pagination":{"page":1,"pageSize":20,"total":1}}` | Staff@rạp / Manager@rạp / Admin |
| GET | `/api/v1/operations/bookings` | Danh sách đơn quản lý theo rạp | `?cinemaId=c1&showtimeId=st1&status=confirmed&page=1` | 200 `{"items":[{"id":"b1","showtimeId":"st1","status":"confirmed","totalVnd":160000}],"pagination":{"page":1,"pageSize":20,"total":1}}` | Manager@rạp / Admin |
| GET | `/api/v1/operations/bookings/{bookingId}` | Chi tiết đơn trong phạm vi quản lý | `bookingId` | 200 `{"id":"b1","showtimeId":"st1","status":"confirmed","totalVnd":160000}` | Manager@rạp / Admin |

#### Quản trị suất chiếu và thống kê

| Method | Endpoint | Mô tả | Request Body / Params | Response mẫu (JSON) | Phân quyền |
|---|---|---|---|---|---|
| GET | `/api/v1/operations/showtimes` | Danh sách suất vận hành | `?cinemaId=c1&date=2026-12-20&status=on_sale&page=1` | 200 `{"items":[{"id":"st1","status":"on_sale"}],"pagination":{"page":1,"pageSize":20,"total":1}}` | Manager@rạp / Admin |
| POST | `/api/v1/operations/showtimes` | Tạo suất, kiểm tra lịch trùng | `{"movieId":"m1","auditoriumId":"a1","startsAt":"2026-12-20T12:30:00Z","format":"2D"}` | 201 `{"id":"st1","status":"draft"}` | Manager@rạp / Admin |
| PUT | `/api/v1/operations/showtimes/{showtimeId}` | Cập nhật thông tin suất ở draft | `{"movieId":"m1","auditoriumId":"a1","startsAt":"2026-12-20T12:30:00Z","format":"2D"}` | 200 `{"id":"st1","status":"draft"}` | Manager@rạp / Admin |
| PUT | `/api/v1/operations/showtimes/{showtimeId}/status` | Chuyển trạng thái suất hợp lệ | `{"status":"on_sale"}` | 200 `{"id":"st1","status":"on_sale"}` | Manager@rạp / Admin |
| DELETE | `/api/v1/operations/showtimes/{showtimeId}` | Xóa suất draft chưa có giao dịch | `showtimeId` | 200 `{"id":"st1","deleted":true}` | Manager@rạp / Admin |
| GET | `/api/v1/operations/reports/sales` | Báo cáo doanh thu, vé, lấp đầy | `?fromDate=2026-12-01&toDate=2026-12-31&cinemaId=c1&movieId=m1&groupBy=movie&page=1` | 200 `{"items":[{"movieId":"m1","netRevenueVnd":160000,"ticketCount":1,"soldSeatCount":1,"capacity":100,"occupancyRate":0.01}],"pagination":{"page":1,"pageSize":20,"total":1}}` | Manager@rạp / Admin |

#### Quản trị danh mục

| Method | Endpoint | Mô tả | Request Body / Params | Response mẫu (JSON) | Phân quyền |
|---|---|---|---|---|---|
| GET | `/api/v1/admin/cinemas` | Liệt kê cinemas | `?page=1` | 200 `{"items":[{"id":"c1","name":"Cinema Quận 1","address":"Quận 1, TP HCM","status":"active"}],"pagination":{"page":1,"pageSize":20,"total":1}}` | Admin |
| POST | `/api/v1/admin/cinemas` | Tạo cinemas | `{"name":"Cinema Quận 1","address":"Quận 1, TP HCM","status":"active"}` | 201 `{"id":"c1","name":"Cinema Quận 1","address":"Quận 1, TP HCM","status":"active"}` | Admin |
| GET | `/api/v1/admin/cinemas/{id}` | Đọc chi tiết cinemas | `id` | 200 `{"id":"c1","name":"Cinema Quận 1","address":"Quận 1, TP HCM","status":"active"}` | Admin |
| PUT | `/api/v1/admin/cinemas/{id}` | Cập nhật cinemas | `{"name":"Cinema Quận 1","address":"Quận 1, TP HCM","status":"active"}` | 200 `{"id":"c1","name":"Cinema Quận 1","address":"Quận 1, TP HCM","status":"active"}` | Admin |
| DELETE | `/api/v1/admin/cinemas/{id}` | Xóa nếu chưa tham chiếu hoặc trả 409 | `id` | 200 `{"id":"c1","deleted":true}` | Admin |
| GET | `/api/v1/admin/auditoriums` | Liệt kê auditoriums | `?page=1` | 200 `{"items":[{"id":"a1","cinemaId":"c1","name":"Phòng 1","status":"active"}],"pagination":{"page":1,"pageSize":20,"total":1}}` | Admin |
| POST | `/api/v1/admin/auditoriums` | Tạo auditoriums | `{"cinemaId":"c1","name":"Phòng 1","status":"active"}` | 201 `{"id":"a1","cinemaId":"c1","name":"Phòng 1","status":"active"}` | Admin |
| GET | `/api/v1/admin/auditoriums/{id}` | Đọc chi tiết auditoriums | `id` | 200 `{"id":"a1","cinemaId":"c1","name":"Phòng 1","status":"active"}` | Admin |
| PUT | `/api/v1/admin/auditoriums/{id}` | Cập nhật auditoriums | `{"cinemaId":"c1","name":"Phòng 1","status":"active"}` | 200 `{"id":"a1","cinemaId":"c1","name":"Phòng 1","status":"active"}` | Admin |
| DELETE | `/api/v1/admin/auditoriums/{id}` | Xóa nếu chưa tham chiếu hoặc trả 409 | `id` | 200 `{"id":"a1","deleted":true}` | Admin |
| GET | `/api/v1/admin/seats` | Liệt kê seats | `?page=1` | 200 `{"items":[{"id":"s1","auditoriumId":"a1","rowLabel":"A","seatNumber":1,"kind":"standard","x":1,"y":1,"isActive":true}],"pagination":{"page":1,"pageSize":20,"total":1}}` | Admin |
| POST | `/api/v1/admin/seats` | Tạo seats | `{"auditoriumId":"a1","rowLabel":"A","seatNumber":1,"kind":"standard","x":1,"y":1,"isActive":true}` | 201 `{"id":"s1","auditoriumId":"a1","rowLabel":"A","seatNumber":1,"kind":"standard","x":1,"y":1,"isActive":true}` | Admin |
| GET | `/api/v1/admin/seats/{id}` | Đọc chi tiết seats | `id` | 200 `{"id":"s1","auditoriumId":"a1","rowLabel":"A","seatNumber":1,"kind":"standard","x":1,"y":1,"isActive":true}` | Admin |
| PUT | `/api/v1/admin/seats/{id}` | Cập nhật seats | `{"auditoriumId":"a1","rowLabel":"A","seatNumber":1,"kind":"standard","x":1,"y":1,"isActive":true}` | 200 `{"id":"s1","auditoriumId":"a1","rowLabel":"A","seatNumber":1,"kind":"standard","x":1,"y":1,"isActive":true}` | Admin |
| DELETE | `/api/v1/admin/seats/{id}` | Xóa nếu chưa tham chiếu hoặc trả 409 | `id` | 200 `{"id":"s1","deleted":true}` | Admin |
| GET | `/api/v1/admin/genres` | Liệt kê genres | `?page=1` | 200 `{"items":[{"id":"g1","name":"Phiêu lưu"}],"pagination":{"page":1,"pageSize":20,"total":1}}` | Admin |
| POST | `/api/v1/admin/genres` | Tạo genres | `{"name":"Phiêu lưu"}` | 201 `{"id":"g1","name":"Phiêu lưu"}` | Admin |
| GET | `/api/v1/admin/genres/{id}` | Đọc chi tiết genres | `id` | 200 `{"id":"g1","name":"Phiêu lưu"}` | Admin |
| PUT | `/api/v1/admin/genres/{id}` | Cập nhật genres | `{"name":"Phiêu lưu"}` | 200 `{"id":"g1","name":"Phiêu lưu"}` | Admin |
| DELETE | `/api/v1/admin/genres/{id}` | Xóa nếu chưa tham chiếu hoặc trả 409 | `id` | 200 `{"id":"g1","deleted":true}` | Admin |
| GET | `/api/v1/admin/movies` | Liệt kê movies | `?page=1` | 200 `{"items":[{"id":"m1","title":"Mặt Trời","slug":"mat-troi","synopsis":"Phim mẫu","posterUrl":"https://example.test/poster.jpg","trailerUrl":"https://www.youtube.com/watch?v=DEMO_VIDEO1","durationMinutes":100,"ageRating":"P","releaseDate":"2026-12-20","genreIds":["g1"],"status":"now_showing"}],"pagination":{"page":1,"pageSize":20,"total":1}}` | Admin |
| POST | `/api/v1/admin/movies` | Tạo movies | `{"title":"Mặt Trời","slug":"mat-troi","synopsis":"Phim mẫu","posterUrl":"https://example.test/poster.jpg","trailerUrl":"https://www.youtube.com/watch?v=DEMO_VIDEO1","durationMinutes":100,"ageRating":"P","releaseDate":"2026-12-20","genreIds":["g1"],"status":"now_showing"}` | 201 `{"id":"m1","title":"Mặt Trời","slug":"mat-troi","synopsis":"Phim mẫu","posterUrl":"https://example.test/poster.jpg","trailerUrl":"https://www.youtube.com/watch?v=DEMO_VIDEO1","durationMinutes":100,"ageRating":"P","releaseDate":"2026-12-20","genreIds":["g1"],"status":"now_showing"}` | Admin |
| GET | `/api/v1/admin/movies/{id}` | Đọc chi tiết movies | `id` | 200 `{"id":"m1","title":"Mặt Trời","slug":"mat-troi","synopsis":"Phim mẫu","posterUrl":"https://example.test/poster.jpg","trailerUrl":"https://www.youtube.com/watch?v=DEMO_VIDEO1","durationMinutes":100,"ageRating":"P","releaseDate":"2026-12-20","genreIds":["g1"],"status":"now_showing"}` | Admin |
| PUT | `/api/v1/admin/movies/{id}` | Cập nhật movies | `{"title":"Mặt Trời","slug":"mat-troi","synopsis":"Phim mẫu","posterUrl":"https://example.test/poster.jpg","trailerUrl":"https://www.youtube.com/watch?v=DEMO_VIDEO1","durationMinutes":100,"ageRating":"P","releaseDate":"2026-12-20","genreIds":["g1"],"status":"now_showing"}` | 200 `{"id":"m1","title":"Mặt Trời","slug":"mat-troi","synopsis":"Phim mẫu","posterUrl":"https://example.test/poster.jpg","trailerUrl":"https://www.youtube.com/watch?v=DEMO_VIDEO1","durationMinutes":100,"ageRating":"P","releaseDate":"2026-12-20","genreIds":["g1"],"status":"now_showing"}` | Admin |
| DELETE | `/api/v1/admin/movies/{id}` | Xóa nếu chưa tham chiếu hoặc trả 409 | `id` | 200 `{"id":"m1","deleted":true}` | Admin |
| GET | `/api/v1/admin/price-rules` | Liệt kê price-rules | `?page=1` | 200 `{"items":[{"id":"pr1","cinemaId":"c1","format":"2D","seatKind":"standard","amountVnd":95000,"active":true}],"pagination":{"page":1,"pageSize":20,"total":1}}` | Admin |
| POST | `/api/v1/admin/price-rules` | Tạo price-rules | `{"cinemaId":"c1","format":"2D","seatKind":"standard","amountVnd":95000,"active":true}` | 201 `{"id":"pr1","cinemaId":"c1","format":"2D","seatKind":"standard","amountVnd":95000,"active":true}` | Admin |
| GET | `/api/v1/admin/price-rules/{id}` | Đọc chi tiết price-rules | `id` | 200 `{"id":"pr1","cinemaId":"c1","format":"2D","seatKind":"standard","amountVnd":95000,"active":true}` | Admin |
| PUT | `/api/v1/admin/price-rules/{id}` | Cập nhật price-rules | `{"cinemaId":"c1","format":"2D","seatKind":"standard","amountVnd":95000,"active":true}` | 200 `{"id":"pr1","cinemaId":"c1","format":"2D","seatKind":"standard","amountVnd":95000,"active":true}` | Admin |
| DELETE | `/api/v1/admin/price-rules/{id}` | Xóa nếu chưa tham chiếu hoặc trả 409 | `id` | 200 `{"id":"pr1","deleted":true}` | Admin |
| GET | `/api/v1/admin/combos` | Liệt kê combos | `?page=1` | 200 `{"items":[{"id":"co1","cinemaId":"c1","name":"Combo Bắp Nước","priceVnd":65000,"active":true}],"pagination":{"page":1,"pageSize":20,"total":1}}` | Admin |
| POST | `/api/v1/admin/combos` | Tạo combos | `{"cinemaId":"c1","name":"Combo Bắp Nước","priceVnd":65000,"active":true}` | 201 `{"id":"co1","cinemaId":"c1","name":"Combo Bắp Nước","priceVnd":65000,"active":true}` | Admin |
| GET | `/api/v1/admin/combos/{id}` | Đọc chi tiết combos | `id` | 200 `{"id":"co1","cinemaId":"c1","name":"Combo Bắp Nước","priceVnd":65000,"active":true}` | Admin |
| PUT | `/api/v1/admin/combos/{id}` | Cập nhật combos | `{"cinemaId":"c1","name":"Combo Bắp Nước","priceVnd":65000,"active":true}` | 200 `{"id":"co1","cinemaId":"c1","name":"Combo Bắp Nước","priceVnd":65000,"active":true}` | Admin |
| DELETE | `/api/v1/admin/combos/{id}` | Xóa nếu chưa tham chiếu hoặc trả 409 | `id` | 200 `{"id":"co1","deleted":true}` | Admin |

#### REST nội bộ giữa ba dịch vụ

| Method | Endpoint | Mô tả | Request Body / Params | Response mẫu (JSON) | Phân quyền |
|---|---|---|---|---|---|
| POST | `/api/v1/internal/payments` · payment | Core yêu cầu tạo giao dịch | `{"bookingRef":"b1","amountVnd":160000,"currency":"VND","expiresAt":"2026-12-20T11:05:00Z"} · Idempotency-Key` | 201 `{"id":"p1","status":"pending"}` | Service · Core → Payment |
| POST | `/api/v1/internal/payments/{paymentId}/simulations` · payment | Core yêu cầu mô phỏng kết quả | `{"outcome":"succeeded"}` | 202 `{"id":"p1","status":"processing"}` | Service · Core → Payment |
| POST | `/api/v1/internal/payments/{paymentId}/refunds` · payment | Core yêu cầu hoàn tiền giả lập | `{"amountVnd":160000,"reason":"booking_cancellation"} · Idempotency-Key` | 202 `{"refundId":"rf1","status":"pending"}` | Service · Core → Payment |
| POST | `/api/v1/internal/payment-events` | Nhận webhook thanh toán hoặc hoàn tiền | `{"eventId":"ev1","type":"payment.succeeded","paymentId":"p1","bookingRef":"b1","amountVnd":160000,"currency":"VND"} · X-Webhook-Timestamp, X-Webhook-Signature` | 200 `{"accepted":true}` | Service · Payment → Core + HMAC |
| POST | `/api/v1/internal/notifications` · notification | Đưa email vào hàng gửi theo mẫu | `{"template":"ticket_issued","recipient":"linh@example.test","data":{"bookingId":"b1","bookingCode":"DEMO-GUEST-CODE","tickets":[{"seatLabel":"A1","qrToken":"mock_ticket_qr_token"}]}} · Idempotency-Key` | 200 `{"id":"n1","status":"sent","providerMessageId":"demo-provider-message-id"}`; 202 khi cùng yêu cầu đang xử lý | Service · Core → Notification |

**Chi tiết tích hợp**

- Public đọc phim/lịch/sơ đồ ghế. Guest nhận `holdToken` khi giữ ghế và gửi `X-Hold-Token` khi tạo đơn hoặc nhả ghế. Tạo đơn trả mã tra cứu. Guest gửi mã trong body khi tra cứu và trong `X-Booking-Code` khi thao tác trên đơn. Client giữ mã trong bộ nhớ cho phiên checkout và cho phép người dùng nhập lại từ email. Log loại trừ các mã, token và contact. Lookup trả dữ liệu vé tối thiểu và được giới hạn tần suất.
- Sau khi tạo payment, giao diện demo gửi kết quả mô phỏng qua Core, rồi polling `GET /bookings/{bookingId}` với tài khoản hoặc `POST /bookings/lookup` với guest. Core đổi trạng thái sau khi xác minh webhook. Hai kết quả mô phỏng là `succeeded` và `failed`. API mô phỏng chỉ mở khi bật cấu hình demo. Email vé chứa QR của từng ghế. Mẫu email xác thực và đặt lại mật khẩu dùng trường `data.actionUrl`; mẫu vé dùng `bookingId`, `bookingCode` và `tickets`.
- Core cấp JWT 15 phút, xác minh thuật toán/chữ ký, `iss`, `aud`, `exp`; refresh là chuỗi ngẫu nhiên lưu hash, xoay liên tục và phát hiện dùng lại. Dùng cookie `HttpOnly; Secure; SameSite=Strict; Path=/api/v1/auth`. Xác minh Origin ở endpoint dùng cookie. Khi triển khai, đặt SPA và Core cùng site HTTPS, ưu tiên reverse proxy qua cùng origin. Trong phát triển, cấu hình frontend/API nhất quán về hostname. Kiểm tra refresh thật trong môi trường HTTPS. Phân quyền theo vai trò, phạm vi rạp và sở hữu tài nguyên ngay tại server.
- Nội bộ gửi token dịch vụ ký Ed25519, kiểm `aud`, `scope`, thời hạn tối đa 60 giây và API key riêng cho từng kết nối. Webhook dùng HMAC trên timestamp và raw body, kiểm thời gian tối đa 5 phút, so sánh chữ ký thời gian hằng, chống lặp theo event ID. Khi retry, ký lại bằng timestamp mới và giữ event ID. Kiểm tra account, key, rate limit, bảo mật thông tin và race condition trong CI.
- Dùng Knex parameter binding, Zod và danh sách sort cho phép. Giới hạn request body, rate-limit theo route, giới hạn PostgreSQL statement timeout và timeout gọi dịch vụ. Trả DTO theo danh sách trường cho phép và giữ token khỏi log. Các endpoint thay đổi quyền, tạo đơn và webhook cần test nhánh lỗi theo mục bảo mật của đề.

## 3. Khung cấu hình mẫu & Cấu trúc thư mục (Project Skeleton & Config)

Dùng **monorepo** để một PR có thể sửa hợp đồng API, mock và module phụ trách cùng lúc. Cây dưới mô tả đích tổ chức. Gói starter đã có entry point, cấu hình, OpenAPI, mock, kết nối DB, error middleware và Axios. Các thư mục feature, migration và test được tạo khi nhóm thực hiện module.

```text
cinema-starter/
├── .env.example
├── .gitignore
├── docker-compose.yml
├── package.json
├── README.md
├── .github/workflows/ci.yml                # Tuần 1–2
├── contracts/
│   ├── openapi.core.json
│   ├── openapi.payment.json
│   └── openapi.notification.json
├── packages/server/
│   ├── db.js
│   └── http.js
├── services/
│   ├── api/                               # Express 5 · Core
│   │   ├── src/server.js
│   │   ├── src/modules/                   # auth, users, catalog, showtimes,
│   │   │                                  # booking, tickets, reporting
│   │   ├── db/{migrations,seeds}/
│   │   └── test/
│   ├── payment/                           # Express 5 · Payment simulator
│   │   ├── src/server.js
│   │   ├── src/modules/                   # payments, refunds, webhooks
│   │   ├── db/{migrations,seeds}/
│   │   └── test/
│   └── notification/                      # Express 5 · SMTP/templates
│       ├── src/server.js
│       ├── src/modules/                   # jobs, email, qr
│       ├── db/{migrations,seeds}/
│       └── test/
├── apps/web/                              # React 19/Vite SPA do AI tạo
│   ├── .env.example
│   ├── vercel.json.example
│   └── src/
│       ├── api/client.js
│       ├── app/                           # Router, providers, layout
│       ├── features/                      # auth, catalog, checkout, profile, operations
│       └── components/
├── scripts/mock.mjs
└── tests/e2e/                             # Playwright
```

Trong từng feature backend, tách `routes → controller → service → repository`. Route/controller xác thực và xử lý HTTP, service giữ quy tắc nghiệp vụ và biên giao dịch, repository xử lý Knex. Zod schema và ví dụ được dùng để cập nhật OpenAPI 3.1 đồng bộ khi tích hợp. Trang chia sẻ SSR có thể là route Express riêng trả HTML đã escape; React Router chạy SPA theo Data Router.

### Chạy mock và cấu hình local

```bash
npm run mock
# Core: http://localhost:4010/api/v1
# Payment: http://localhost:4011/api/v1
# Notification: http://localhost:4012/api/v1
curl http://localhost:4010/api/v1/movies
curl -X POST 'http://localhost:4010/api/v1/showtimes/st1/holds?__status=409'
```

Đặt `VITE_API_BASE_URL=http://localhost:4010/api/v1` trong môi trường khi dựng SPA từ mock. Mock phục vụ fixture tĩnh từ OpenAPI và chọn mẫu lỗi qua `__status`. API mock bỏ qua kiểm tra quyền, cookie, body và bộ lọc nghiệp vụ. Khi cần mô phỏng đổi ghế, chuyển đơn hoặc phân quyền thật, chạy backend và dữ liệu seed theo từng luồng. Tất cả cổng mock dành cho môi trường phát triển.

```bash
cp .env.example .env
docker compose up -d
npm install
npm run dev:api
# Chạy ở các terminal riêng khi cần
npm run dev:payment
npm run dev:notification
curl http://localhost:3000/health
```

Compose mặc định chạy một PostgreSQL chứa ba schema. Thêm `--profile mail` để chạy Mailpit local. Ba Express chạy qua Node 22+ với health check, logging và chuẩn lỗi. Khi hoàn tất nghiệp vụ, N5 bổ sung Dockerfile, migration/seed lúc khởi tạo và cấu hình chạy cả ba Express cùng SPA bằng một lệnh Compose theo yêu cầu nộp. Mailpit dùng SMTP cổng 1025, giao diện đọc thư tại `http://localhost:8025`.

`.env.example` ở gốc chứa URL DB từng dịch vụ, cổng, Origin, JWT/cookie, thông số giữ/hủy, giới hạn request, URL nội bộ, khóa dịch vụ và SMTP. `apps/web/.env.example` chỉ có `VITE_API_BASE_URL`. Khóa mẫu để trống cho luồng nghiệp vụ. Trên cloud, cấp kho bí mật riêng và kiểm tra cấu hình bắt buộc khi khởi động từng dịch vụ sau khi module auth và liên dịch vụ được kết nối.

### Triển khai Vercel → Render → Supabase

| Thành phần | Cấu hình dự kiến | Kiểm tra sau triển khai |
|---|---|---|
| **Vercel · React/Vite** | Root Directory `apps/web`, framework Vite, đầu ra `dist`. Đặt `VITE_API_BASE_URL=/api/v1`. Chép `vercel.json.example` thành `vercel.json` và thay hostname Core. Giữ rewrite API và trang chia sẻ trước fallback SPA. | Mở trực tiếp URL chi tiết phim, thử trang chia sẻ, lưu cookie khi đăng nhập, tải lại và kiểm tra refresh, logout. |
| **Render · Core** | Tạo Node Web Service, dùng gốc monorepo, Build `npm install` ở bản khung hoặc `npm ci` sau khi có lockfile, Start `npm start`. Đặt `NODE_ENV=production`, `WEB_ORIGIN` đúng origin Vercel, `CORE_DATABASE_URL`, URL Payment/Notification và khóa Core. Health check `/health`. | Core kết nối đúng Supabase, Swagger UI công khai sau khi lắp module docs, các route API qua Vercel trả JSON. |
| **Render · Payment / Notification** | Tạo hai Web Service từ cùng repo. Dùng `npm run start:payment` và `npm run start:notification`. Cấp URL DB, API key và token dịch vụ theo đúng thành phần. Payment gọi webhook trực tiếp tới Core Render. Notification nhận cấu hình gửi email. | Thanh toán giả lập tạo vé đúng một lần. Email xác thực và vé QR đến địa chỉ demo. Kiểm tra `/health` từng dịch vụ. |
| **Supabase · PostgreSQL** | Một project Free, ba schema với ba role runtime giới hạn quyền. Lấy URL **Session pooler** từ mục Connect khi cần IPv4. Dùng role giới hạn quyền, TLS xác minh chứng thư và Knex pool nhỏ, khởi điểm 3 kết nối/instance. Chạy migration cho từng DB, sau đó seed dữ liệu demo. | Cả ba health check truy vấn được DB. Role của mỗi dịch vụ chỉ có quyền với dữ liệu của dịch vụ đó. Không có URL DB hoặc mật khẩu trong bundle Vercel. |

Mẫu này để browser gọi `/api/v1` trên chính miền Vercel qua rewrite sang Core Render. Cookie refresh dùng `Secure; HttpOnly; SameSite=Strict`, không đặt thuộc tính `Domain`; Core kiểm tra `Origin` cho các yêu cầu dùng cookie. Đặt `WEB_ORIGIN` theo đúng URL bản demo, dùng một hostname nhất quán khi thử đăng nhập và refresh. Payment và Notification gọi qua URL Render với xác thực dịch vụ; browser chỉ gọi Core.

**Các bước đưa lên cloud**

1. Tạo một project Supabase Free, chạy đủ ba khối schema, migration Notification và script role. Lấy URL Session Pooler và cấu hình TLS. Dùng username riêng theo role ở từng dịch vụ. Trong Render đặt URL tương ứng cho mỗi dịch vụ, `DB_SSL_MODE=verify-full` và `DB_POOL_MAX=3`. Nếu CA của endpoint không nằm trong trust store của Node, đặt `DB_SSL_CA_FILE` tới CA đúng cho endpoint.
2. Tạo ba dịch vụ Render. Mỗi dịch vụ lắng nghe `PORT` do Render cấp, dùng `0.0.0.0`. Điền toàn bộ biến cho các module đã tích hợp theo `.env.example`, chạy migration/seed và kiểm tra health. Dùng các URL HTTPS thật để điền `CORE_BASE_URL`, `PAYMENT_BASE_URL` và `NOTIFICATION_BASE_URL` tùy phía gọi. Các URL nội bộ có hậu tố `/api/v1`.
3. Deploy SPA lên Vercel từ `apps/web`, thay hostname Core trong rewrite và chạy thử refresh cookie, liên kết vào thẳng trang phim, phát trailer, thanh toán giả lập và email QR. N5 ghi URL SPA/Swagger vào README, dùng đúng môi trường này để quay video báo cáo.

**Phương án Free đã chốt.** Notification gửi qua Resend HTTPS đến inbox demo; Mailpit phục vụ local. Xem [runbook](../runbooks/deploy-free-and-email.md) để thiết lập role, biến môi trường và chạy email thử.

Tài liệu triển khai: [Vercel Rewrites](https://vercel.com/docs/routing/rewrites), [Vite on Vercel](https://vercel.com/docs/frameworks/frontend/vite), [Render Express](https://render.com/docs/deploy-node-express-app), [Render Free](https://render.com/docs/free), [Render SMTP](https://render.com/articles/can-i-send-email-over-smtp-from-render), [Supabase Connect](https://supabase.com/docs/guides/database/connecting-to-postgres), [Supabase Billing FAQ](https://supabase.com/docs/guides/platform/billing-faq).

### API response và Global Error Handling

`send(res, 201, payload)` trả HTTP 201 và JSON:

```json
{
  "success": true,
  "statusCode": 201,
  "message": "OK",
  "data": { "id": "h1", "expiresAt": "2026-12-20T11:05:00Z" }
}
```

`throw new AppError(409, "SEAT_UNAVAILABLE", "Ghế đã được giữ")` trả HTTP 409:

```json
{
  "success": false,
  "statusCode": 409,
  "message": "Ghế đã được giữ",
  "error": { "code": "SEAT_UNAVAILABLE", "details": [] },
  "requestId": "req_demo"
}
```

`packages/server/http.js` đăng ký middleware lỗi cuối pipeline. Zod lỗi → 422, JSON sai → 400, body quá lớn → 413, tài nguyên không có/không thuộc người dùng khi cần che sự tồn tại → 404, lỗi bất ngờ → 500. Lỗi nghiệp vụ khác dùng 401, 403, 409 hoặc 429. Mọi response có header `X-Request-Id`. Trong bản tích hợp, truyền mã tương quan đã xác minh sang các dịch vụ nội bộ.

`packages/server/db.js` tạo Knex pool riêng theo biến môi trường của dịch vụ. `apps/web/src/api/client.js` giữ access token trong bộ nhớ, dùng Axios client riêng cho cookie, ghép các lần refresh đồng thời trong cùng tab và chỉ thử lại request một lần. Gọi `restoreSession()` khi khởi tạo app. Các form dùng trực tiếp `error.code` và `error.details`; khi refresh thất bại, router xử lý trạng thái phiên hết hạn. POST có thể được thử lại cần giữ nguyên `Idempotency-Key`.

## 4. Quy tắc làm việc nhóm trên Git (Git Workflow)

| Nội dung | Quy tắc |
|---|---|
| Nhánh chính | Bảo vệ `main`. Chỉ đưa thay đổi vào qua PR, có ít nhất một người review và CI xanh. Dùng nhánh ngắn theo task. |
| Đặt tên nhánh | `feat/booking-seat-hold`, `fix/payment-event-retry`, `test/booking-race`, `docs/openapi-contract`, `chore/compose-local`. |
| Commit | Conventional Commits theo `type(scope): mô tả ngắn`. Ví dụ `feat(booking): reserve seats atomically`, `fix(auth): rotate refresh sessions`, `test(payment): cover duplicate webhook events`. |
| PR | Gắn issue, mô tả thay đổi, cách chạy test, ảnh hưởng đến API/migration và biến cấu hình. PR sửa hợp đồng cập nhật OpenAPI, ví dụ và mock cùng lúc. |
| Review theo phụ thuộc | N1 review auth/quyền. N2 review truy vấn, schema danh mục và lịch. N3/N4 review chéo giao dịch, webhook, refund. N5 review Compose/CI và nghiệm thu E2E. Phải có người khác duyệt PR. |
| Migration và môi trường | Migration có tên và thứ tự rõ ràng. Migration đã merge được sửa bằng migration tiếp theo. Commit lockfile sau khi cài dependency. Commit `.env.example`; cấu hình thật đi qua biến môi trường/secret. |
| CI trên mỗi PR | Lint/format, Vitest/Supertest với DB test, React Testing Library, Playwright trên Compose và kiểm tra OpenAPI 3.1. Xuất coverage `services/api`, chạy `npm audit` và kiểm tra dữ liệu bí mật trong repo/bundle. |
| Merge và chứng minh đóng góp | Squash merge từng PR và giữ Conventional Commit cho tiêu đề squash. Mỗi thành viên mở PR bằng tài khoản mình, có lịch sử commit và ghi nhận co-author nếu cùng làm. Sau merge, xóa nhánh task. |
| Phát hành | Tạo tag `v0.1.0` khi 5 luồng chạy trên cloud, có seed, Swagger UI, kết quả CI và checklist nộp. |

Ví dụ thực hiện một task:

```bash
git switch main
git pull --ff-only
git switch -c feat/booking-seat-hold
git add services/api contracts
git commit -m "feat(booking): reserve seats atomically"
git push -u origin feat/booking-seat-hold
```
