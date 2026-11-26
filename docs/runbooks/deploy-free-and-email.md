# Triển khai Free và demo email

Dùng **Vercel Hobby**, **ba Render Free Web Service**, **một project Supabase Free với ba schema** và **Resend Free qua HTTPS**. Chế độ dùng địa chỉ gửi thử của Resend gửi email đến hộp thư của chính tài khoản Resend. Nhóm đã chấp nhận cô lập theo schema trong cùng project. Core, Payment và Notification vẫn gọi nhau qua API.

## Supabase · một project, ba role

Trong SQL Editor của cùng một project, chạy toàn bộ từng file theo thứ tự:

1. [001_init_schema.sql](../../database/001_init_schema.sql)
2. [002_notification_delivery.sql](../../database/002_notification_delivery.sql)
3. [003_supabase_roles.sql](../../database/003_supabase_roles.sql)
4. [seed.sql](../../database/seed.sql) nếu đây là project dành cho demo. Seed có mật khẩu mẫu công khai.

Script cấp cho mỗi role quyền DML trong đúng schema của nó. Sau khi chạy, thiết lập mật khẩu ngẫu nhiên khác nhau cho từng role và bật LOGIN. Các giá trị sau chỉ minh họa, thay bằng bí mật riêng trong SQL Editor:

```sql
ALTER ROLE cinema_core_app LOGIN PASSWORD 'REPLACE_WITH_CORE_PASSWORD';
ALTER ROLE cinema_payment_app LOGIN PASSWORD 'REPLACE_WITH_PAYMENT_PASSWORD';
ALTER ROLE cinema_notification_app LOGIN PASSWORD 'REPLACE_WITH_NOTIFICATION_PASSWORD';
```

Đừng đưa câu lệnh đã điền mật khẩu vào Git. Không expose các schema này qua Supabase Data API. Kiểm tra phân quyền với vai trò tương ứng trước khi dùng trong môi trường chấm:

```sql
SELECT has_table_privilege('cinema_notification_app', 'cinema_notification.notification_jobs', 'INSERT') AS can_insert_jobs,
       has_schema_privilege('cinema_notification_app', 'cinema_core', 'USAGE') AS can_read_core_schema;
-- Mong đợi: true, false.
```

Sao chép hostname Supavisor **Session pooler** cổng `5432` ở mục **Connect**. Cả ba URI cùng hostname và `project-ref`, mỗi dịch vụ có username/mật khẩu riêng:

```text
postgresql://cinema_core_app.<project-ref>:<encoded-password>@<pooler-host>:5432/postgres
postgresql://cinema_payment_app.<project-ref>:<encoded-password>@<pooler-host>:5432/postgres
postgresql://cinema_notification_app.<project-ref>:<encoded-password>@<pooler-host>:5432/postgres
```

Đặt URI tương ứng vào `DATABASE_URL` của từng Render service. Code dùng TLS `verify-full` mặc định và pool max 3 kết nối/instance. Giữ DB và khóa email ở backend. Nếu cần CA tùy chỉnh đặt `DB_SSL_CA_FILE`. Không cấu hình cả `sslmode` trong URI và TLS trong code.

## Chuẩn bị khóa dịch vụ

Từ gốc repo, tạo bộ khóa cho môi trường demo:

```bash
mkdir -p .secrets
openssl genpkey -algorithm ED25519 -out .secrets/core-private.pem
openssl pkey -in .secrets/core-private.pem -pubout -out .secrets/core-public.pem
openssl rand -hex 32
```

Lưu chuỗi ngẫu nhiên vào `CORE_TO_NOTIFICATION_API_KEY` trong `.env` local và Render Notification. Khóa riêng chỉ ở máy chạy CLI hoặc dịch vụ phát JWT trong giai đoạn tích hợp. Notification giữ khóa công khai. Repo bỏ qua `.secrets/`, `*.pem` và `.env`.

## Demo qua Render và Resend

1. Tạo Resend API key chỉ có quyền gửi, dùng địa chỉ email của chủ tài khoản làm inbox demo.
2. Trong Render Notification, đặt các biến dưới đây. Core và Payment giữ các biến được mô tả trong [README](../../README.md).

| Biến | Giá trị |
|---|---|
| `MAIL_TRANSPORT` | `resend` |
| `MAIL_FROM` | `Cinema <onboarding@resend.dev>` |
| `MAIL_DEMO_RECIPIENT` | Đúng email đăng ký Resend |
| `MAIL_ACTION_ORIGIN` | URL HTTPS của SPA Vercel |
| `RESEND_API_KEY` | Key Resend của nhóm |
| `CORE_TO_NOTIFICATION_API_KEY` | Chuỗi ngẫu nhiên riêng cho Core → Notification |
| `CORE_SERVICE_PUBLIC_KEY` | Nội dung PEM từ `.secrets/core-public.pem` |

3. Tại máy demo, copy `.env.example` thành `.env`. Đặt `CORE_SERVICE_PRIVATE_KEY_FILE=.secrets/core-private.pem`, `CORE_TO_NOTIFICATION_API_KEY`, `MAIL_DEMO_RECIPIENT` và `MAIL_ACTION_ORIGIN` khớp Render. Đặt `NOTIFICATION_BASE_URL=https://<notification>.onrender.com/api/v1`. CLI tự gọi health check rồi tạo JWT ngắn hạn.

```bash
npm ci
npm run demo:email -- verify demo-verify-1
npm run demo:email -- ticket demo-ticket-1
npm run demo:email -- ticket demo-ticket-1
```

Kết quả mong đợi là `200` với `status: sent` và ID nhà cung cấp. Lần gửi lại cùng khóa và payload trả cùng ID. Dùng khóa khác khi cần một email mới. Mở thư và tệp `ve-1.png` trong inbox, kiểm tra Spam nếu chưa thấy. Nhà cung cấp chấp nhận thư là một bước, việc thư xuất hiện trong inbox là bước nghiệm thu riêng. Nếu Resend trả 403, xác nhận lại email người nhận và chế độ gửi thử. Dùng domain đã xác minh nếu sau này cần gửi tới địa chỉ khác.

CLI gửi fixture kiểm tra đường từ Notification tới inbox. Link xác thực fixture mở trang chủ và QR fixture biểu diễn một vé mẫu. Khi nhóm ghép Auth/Booking, Core phải tạo link có token thật, chuyển mã QR của vé đã phát hành và gọi endpoint Notification với cùng cơ chế xác thực. CLI hiện kiểm tra được hai loại thư, chưa minh chứng xác thực tài khoản hoặc soát vé từ email.

## Demo local với Mailpit

Đặt `MAIL_TRANSPORT=smtp`, `MAIL_FROM=Cinema <tickets@example.test>`, `MAIL_DEMO_RECIPIENT=demo@example.test`, `MAIL_ACTION_ORIGIN=http://localhost:5173`. Dùng `CORE_SERVICE_PUBLIC_KEY_FILE=.secrets/core-public.pem` để Notification đọc khóa local, điền API key và private key path như trên. Giữ `NOTIFICATION_BASE_URL=http://localhost:3002/api/v1`.

```bash
docker compose --profile mail up -d --wait
npm run dev:notification
```

Chạy hai lệnh `demo:email` ở terminal khác rồi mở `http://localhost:8025`. Nếu volume Postgres đã có từ starter trước, chạy migration bổ sung một lần:

```bash
docker compose exec -T db psql -v ON_ERROR_STOP=1 -U cinema_local -d cinema_local < database/002_notification_delivery.sql
```

## Nghiệm thu trước demo

- Health của Core, Payment, Notification trả 200 khi deploy. Từng role có quyền đúng schema của nó.
- Endpoint gửi yêu cầu khóa dịch vụ và JWT Ed25519. Demo gửi sai hộp thư phải bị từ chối.
- Inbox nhận hai email có nội dung rõ ràng, thư vé có QR PNG. Gửi lại cùng khóa cho kết quả cũ. Resend giữ khóa ở phía nhà cung cấp trong 24 giờ; app giới hạn ba lượt thử và cửa sổ retry 23 giờ. Local SMTP có thể gửi trùng khi mất kết nối ngay sau khi máy chủ SMTP chấp nhận thư.
- Render có thể sleep. Thử trước giờ demo và giữ bằng chứng local/Mailpit. Trạng thái giữ ghế dùng thời điểm hết hạn trong DB để không phụ thuộc cron.

- [Render Free](https://render.com/docs/free)
- [Supabase Connection Pooler](https://supabase.com/docs/guides/database/connecting-to-postgres)
- [Resend Send Email](https://resend.com/docs/api-reference/emails/send-email)
- [Resend lỗi và phạm vi gửi thử](https://resend.com/docs/api-reference/errors)
- [Resend idempotency](https://resend.com/docs/dashboard/emails/idempotency-keys)
