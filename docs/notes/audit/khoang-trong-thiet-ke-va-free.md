# Đối chiếu thiết kế với đề bài và phương án Free
         
## Quyết định đã chốt

Nhóm dùng một project Supabase Free với ba schema và ba role, đồng thời cần gửi email demo thật. Xem [cấu hình và lệnh kiểm tra](../../runbooks/deploy-free-and-email.md). Các khoảng trống dưới đây đối chiếu starter ban đầu; gói hợp nhất đã bổ sung đường gửi thử qua Notification, còn các luồng tích hợp Auth và Booking vẫn phải thực hiện.

## Kết luận

Bản hiện tại là starter chạy luồng **duyệt phim → lịch chiếu → xem ghế**, với 9 API nghiệp vụ đọc, một SPA danh mục và ba entry point Express. OpenAPI ghi nhiều luồng hơn số đã có code. Auth, quản trị, đặt vé, giao dịch, email, QR, thống kê và E2E 5 luồng là phần việc còn lại. SQL đã có 26 bảng và 180 dòng seed. Tách **khoảng trống trong mô hình** khỏi **endpoint đã thiết kế nhưng chưa triển khai** khi báo cáo tiến độ.

Ưu tiên triển khai một đường xuyên suốt từ mở bán đến nhận vé, rồi thêm chốt quyền, hủy và thống kê. Hàng đợi, WebSocket và upload video sẽ kéo dài đường găng nếu đưa vào bản bắt buộc.

## 1. Database

| Mức | Thiếu hoặc chưa chốt | Hệ quả và cách xử lý gọn |
|---|---|---|
| P0 | **Chưa lưu idempotency của thao tác trên Core.** Hợp đồng yêu cầu actor + operation + key + hash request cho tạo đơn, tạo payment, hủy, nhưng DB Core chỉ có hold UNIQUE và event ID chống lặp webhook. Khóa riêng phía Payment không bảo vệ POST trên Core. | Tạo một bảng nhỏ cho 3 thao tác, UNIQUE trên actor/operation/key, lưu hash và tham chiếu kết quả. Với guest dùng định danh phiên giữ hoặc đơn sau khi xác minh credential. Insert và cập nhật nghiệp vụ trong cùng transaction. Test gửi lại, đổi payload cùng key trả 409 và hai request tới đồng thời. |
| P0 | **Lịch sử tiền thu/hoàn chưa có mẫu có thể truy vấn rõ cho Core.** `payment_attempts` có amount/status; `processed_payment_events` có loại, payload và thời điểm xử lý. Nếu chỉ đọc status cuối thì giao dịch `refunded` làm mất cách phân biệt tiền thu và tiền hoàn. | Mô hình đã đủ cho tổng tiền nếu mỗi event chuẩn hóa amount và lọc event ID một lần. Phương án dễ truy vấn là thêm `amount_vnd`, `occurred_at` vào event Core hoặc ghi một bản ghi thu/hoàn chuẩn hóa. Báo cáo theo **giờ chiếu** là đủ theo lựa chọn hiện tại; chốt timezone ngày và định nghĩa net = thu thành công − hoàn thành công. Tránh tính doanh thu bằng join trực tiếp ghế, combo, event vì sẽ nhân dòng. |
| P1 | **Thiếu snapshot rõ ràng về mẫu số lấp đầy** nếu thay đổi layout sau mở bán. `showtime_seats` đã là snapshot kho ghế theo suất khi giữ nguyên các hàng. | Tạo kho ghế tại lúc mở bán và không xóa hàng kho vì sửa sơ đồ phòng sau đó. Đếm ghế có vé còn hiệu lực/đã soát trên tổng ghế đã mở bán. Ghế đôi tính một vị trí ở cả tử và mẫu; doanh thu là chỉ số riêng. Không cần bảng thống kê lưu sẵn. |
| P1 | **Kiểm tra đúng rạp/chủ đơn và trạng thái phụ thuộc service.** Khóa ngoại ghép đã ràng buộc ghế đúng phòng và booking đúng suất. Nó chưa bảo đảm combo thuộc rạp, customer của hold trùng người đặt, vé chỉ được check-in lúc hợp lệ, hoặc chỉ một lần thanh toán thành công được dùng để phát hành vé. | Kiểm tra trong transaction của Core, khóa bản ghi theo thứ tự thống nhất. Giữ UNIQUE trên ticket check-in và dedup event. Có thể khóa booking khi duyệt callback. Payment đến muộn hoặc giao dịch thành công lần hai phải đi nhánh xử lý hoàn tiền; không phát vé lần hai. |
| P1 | **Trạng thái xử lý ngoài transaction còn mơ hồ khi tiến trình dừng.** Outbox/notification có trạng thái `processing`, attempts và lịch thử lại, nhưng chưa quy định cách lấy lại công việc đã bị bỏ dở. | Nếu làm retry, thêm mốc `claimed_until` hoặc quy tắc reset/khôi phục rõ ràng. Bản Free có thể xử lý ngay sau commit, lưu kết quả và làm thao tác thử lại có giới hạn từ demo; chỉ thêm lịch worker nếu còn giờ. |

**Đã đủ trường nền.** Có phim/thể loại, poster/trailer, rạp/phòng/ghế, giá/combo, người dùng và xác thực, đặt/hủy, giao dịch, vé/check-in. Thống kê theo rạp/phim/thời gian được tính từ các bảng giao dịch; chưa cần bảng report, data warehouse hay Redis. Logging có cấu trúc và request ID thuộc phần vận hành. Đề không bắt buộc lưu nhật ký kiểm toán riêng trong PostgreSQL.

## 2. API, phân quyền và luồng

| Mức | Khoảng trống | Việc cần để đóng |
|---|---|---|
| P0 | **Auth/role/scope chưa thành tính năng chạy được.** Đã có các endpoint Auth/Users trong contract. Mock không kiểm quyền. | Cài JWT/refresh rotation, xác thực email, kiểm quyền ở server và `scopeToCinema`. Kiểm tra Guest, Customer, Staff, Manager, Admin. Staff/Manager bị chặn rạp khác; không chỉ ẩn nút; không cho client tự định phạm vi bằng body/query. |
| P0 | **Quản trị dữ liệu và vòng đời suất chưa chạy.** CRUD và operations showtime đã có trong contract. API đọc công khai chỉ lấy suất phù hợp để bán. | Hoàn thành ít nhất một luồng Admin tạo rạp → phòng → sơ đồ → phim/giá → lịch, và Manager mở bán → bắt đầu → kết thúc tại rạp mình. Tạo kho ghế khi mở bán; thống nhất trạng thái hủy/xóa. |
| P0 | **Đặt vé và mô phỏng thanh toán mới có hợp đồng.** Tạo hold, booking, payment, simulation, receipt/lookup, cancel đều có path nhưng chưa nối DB và UI. | Triển khai một đường happy path cho guest và tài khoản, thử tranh ghế, thất bại, hết hạn và event trùng. `202` của simulation là chấp nhận xử lý. Client quan sát booking; chỉ sinh vé sau khi Core xác minh event. |
| P0 | **Một số ví dụ lỗi OpenAPI chưa khớp nghiệp vụ/thực thi.** Ví dụ login sai cần 401, lọc/ID sai của API đọc hiện có thể trả 422, lookup mã sai cần phản hồi 404 nhất quán, validation và quyền thiếu ở một số operation. | Bổ sung đúng lỗi cho từng operation và test qua mock/HTTP. Test phân quyền dùng API thật. Không lấy trạng thái do query `__status` của mock làm minh chứng nghiệp vụ. |
| P0 | **Email và QR chưa xử lý thật.** Notification đã có entry point và `/internal/notifications` trong contract. Ticket check-in và danh sách khách theo suất đã có path. | Cài gửi email xác thực và email vé QR, ghép xác minh email và soát vé một lần. Lưu hash QR, phạm vi rạp, trạng thái và cách khôi phục gửi. Chuẩn bị email demo đã nhận được. |
| P1 | **Báo cáo chưa chạy và tham số còn mơ hồ.** `GET /operations/reports/sales` đã được định nghĩa, ví dụ hiện tập trung nhóm theo phim. | Chốt `groupBy=movie|cinema|day` (tùy chọn triển khai), khoảng ngày, phạm vi rạp, doanh thu ròng, số vé và lấp đầy. Trả JSON, rà ca refund không double count. Không cần endpoint xuất Excel/PDF để đáp ứng đề. |
| P1 | **Hai điểm thao tác cần chốt rõ để khỏi lệch UI/BE.** Sửa layout từng ghế đã có CRUD, còn lưu toàn bộ layout trong một lần và hủy suất đã mở bán chưa có hành vi rõ trong contract. | Nếu UI sửa hàng loạt, dùng một thao tác ghi giao dịch theo phòng; nếu nhân lực thiếu, chỉnh từng ghế qua CRUD. Giữ hủy suất đã bán là quyết định phạm vi riêng vì kéo theo hoàn tiền hàng loạt. Với đề hiện tại, ưu tiên hủy **đơn** theo chính sách và thao tác Manager theo vòng đời yêu cầu. |

Danh mục Public, lookup guest và quyền quản lý đơn đã có đường dẫn trong thiết kế. Phần thiếu lớn nhất là **code thực thi, phân quyền và test**, không phải thêm hàng loạt path. Nếu muốn khách tải lại vé từ hồ sơ, tái dùng chi tiết đơn đã có; xác định vé được xem lại qua email hay qua tài khoản trước khi thêm API tải vé.

## 3. Dư thừa dễ tiêu tốn thời gian

| Có thể bỏ hoặc thu nhỏ | Phạm vi giữ lại |
|---|---|
| WebSocket, Redis, event bus, hàng đợi ngoài PostgreSQL | Polling ngắn **chỉ trên màn chọn ghế/checkout**, dừng khi rời màn, lùi nhịp khi lỗi. DB kiểm tra lại ở lệnh giữ ghế. |
| Mặc định dùng nhiều tầng outbox/retry với worker luôn chạy | Giữ bản ghi event đã xử lý, idempotency và trạng thái kết quả. Một cơ chế retry có giới hạn và khả năng kiểm tra lại là đủ cho demo. |
| Upload/transcode video, CDN video riêng | `trailer_url` và nút mở nguồn được phép nhúng. Poster dùng URL hoặc asset nhỏ. File video báo cáo nộp bằng link. |
| Cổng thanh toán thật, OAuth Google, LLM, SSR mọi trang | Thanh toán mô phỏng, Auth theo đề, SPA và một trang chia sẻ SSR đã có để đo. |
| PDF/Excel phía server, số liệu tổng hợp lưu sẵn | Báo cáo JSON và biểu đồ/chart đơn giản; CSV phía frontend nếu thật sự cần tải. PDF là tài liệu nộp riêng. |
| Chia thêm backend ngoài ba dịch vụ hoặc tự xây hệ thống định danh máy | Giữ ba Express như đề. Giữ biện pháp xác thực liên dịch vụ được rubric yêu cầu, dùng thư viện và cấu hình chung. Tránh bỏ JWT/cookie, HMAC, scope, test bảo mật để giảm giờ. |

## 4. Triển khai hoàn toàn Free

| Vấn đề | Phương án gọn nhất |
|---|---|
| **Supabase Free chỉ có 2 project hoạt động theo hạn mức tài khoản.** Phương án 3 project riêng của bản thiết kế có thể không vừa hạn mức. | Dùng **1 project, 3 schema và 3 role runtime**, chạy đủ ba khối SQL vào cùng DB, từng service chỉ truy cập schema mình và vẫn gọi nhau qua API. Đây là cô lập logic, không phải 3 database vật lý. **Nhóm đã xác nhận chấp nhận cách này.** Nếu đòi database vật lý, chạy 3 database local để chứng minh, rồi thống nhất phương án cloud với giảng viên hoặc phân bổ project Free thực sự qua các chủ sở hữu có quota, sau khi kiểm tra quyền chia sẻ và quản lý. Không giả định một tài khoản Free có 3 project. |
| **Render Free sleep sau 15 phút không có traffic; 750 giờ/tháng dùng chung workspace** cho Free web services. Free web service không nhận traffic private network. Core, Payment, Notification gọi nhau qua HTTPS công khai và cần xác thực. | Giữ 3 Web Service nhỏ để bám đề, dự trù cold start và quota khi cả ba cùng chạy, kiểm tra trước buổi demo, hiển thị trạng thái đang kết nối và retry có giới hạn. Không dùng ping giữ thức 24/7. Xác minh dự án Supabase chưa bị pause trước khi demo. |
| **Cron và công việc chạy nền.** Render Cron tính phí. Vercel Hobby cron tối thiểu mỗi ngày; timer trong Express dừng khi service sleep/restart. | Giữ ghế hết hạn theo timestamp: khi đọc, coi ghế hết hạn là available; khi giữ mới, xử lý ghế hết hạn trong transaction. Không dùng cron làm điều kiện đúng nghiệp vụ. Dùng `pg_cron` nếu cần dọn dữ liệu trong DB; email/webhook retry tốt nhất thao tác hữu hạn có lưu trạng thái. |
| **Email trên Render Free.** SMTP outbound 25/465/587 bị chặn. Dịch vụ gửi email HTTPS có thể đòi xác minh domain hoặc giới hạn tài khoản test. | Notification dùng email API HTTPS gói Free **sau khi thử được người gửi và người nhận demo**, hoặc SMTP ở cổng khác nếu provider thực sự hỗ trợ và đã test. Mailpit chỉ dùng local. Nếu chưa có domain và chỉ gửi được tới email test, chuẩn bị sẵn tài khoản demo và xin giảng viên chấp nhận minh chứng phụ; đừng mô tả là gửi email phổ thông. |
| **Realtime.** WebSocket có thể mất kết nối khi instance dừng hoặc restart. | Dùng polling khi trang còn hiển thị và checkout định kỳ có giới hạn. Tính đúng do transaction, không do dữ liệu UI. WebSocket là phần mở rộng theo đề. |
| **Upload lớn.** Supabase Storage Free giới hạn tối đa 50 MB mỗi file. Vercel Function có giới hạn body riêng; ứng dụng hiện là SPA và reverse proxy chứ không có Function upload. Render Free dùng filesystem tạm. | Lưu URL trailer. Nếu cần upload poster, upload thẳng vào Storage bằng URL có chữ ký từ Core, hạn chế loại/kích thước; DB lưu object key/URL. Không đẩy video demo/backup lớn vào Git hoặc proxy qua frontend. |
| **Báo cáo PDF/Excel và Git.** Sinh file server chiếm CPU/RAM và thời gian trong lúc cold start. Vercel Hobby có giới hạn liên kết Git và tác giả commit. | Render trả JSON đã phân trang, React vẽ biểu đồ; tải CSV phía trình duyệt nếu cần. Dùng repo cá nhân do người triển khai Hobby sở hữu hoặc xác minh cách deploy được phép. Private repo thuộc GitHub organization có hạn chế tự động deploy trên Hobby. |
| **Không đủ dịch vụ email/DB hoặc chưa chuẩn bị quota** | Ưu tiên một lần chạy demo cloud trọn luồng trước quay video. Ghi lại bằng chứng local và cloud riêng. Giữ `DATABASE_URL` ở Render, dùng Supabase Session Pooler 5432 cho Knex; giữ pool 2–3 kết nối mỗi instance và theo dõi quota/kết nối. |

## Nguồn chính thức

- [Render Free](https://render.com/docs/free) · [Render Cron](https://render.com/docs/cronjobs) · [Render WebSockets](https://render.com/docs/websocket)
- [Supabase Billing FAQ](https://supabase.com/docs/guides/platform/billing-faq) · [Supabase Storage file limits](https://supabase.com/docs/guides/storage/uploads/file-limits) · [Supabase Cron](https://supabase.com/docs/guides/cron) · [Supabase PostgreSQL pooler](https://supabase.com/docs/guides/database/connecting-to-postgres)
- [Vercel Git](https://vercel.com/docs/git) · [Vercel Functions limits](https://vercel.com/docs/functions/limitations) · [Vercel Cron Limits](https://vercel.com/docs/cron-jobs/usage-and-pricing) · [Resend verified domains](https://resend.com/docs/dashboard/domains/introduction)
