# Cinema Ticket Booking System

React/Vite trên Vercel, ba dịch vụ Express trên Render và PostgreSQL Supabase. Xem [mục lục dự án](docs/README.md) để mở bản thiết kế, audit và phiếu giao việc bốn tuần. Dùng [runbook Free và demo email](docs/runbooks/deploy-free-and-email.md) khi cấu hình cloud. Hướng dẫn dưới đây áp dụng cho mã trong gói này.

## Thành phần đã triển khai

| Thành phần | Điểm vào và phạm vi |
|---|---|
| Core | `services/api/src/server.js`, 9 API đọc phim, thể loại, rạp, combo, suất chiếu và ghế. `/docs/` (Swagger UI), `/openapi.json`, `/share/movies/:movieId` (HTML phía server). |
| Payment và Notification | Hai entry point Express và probe riêng. Notification có endpoint nội bộ gửi email demo và tạo tệp QR. Payment còn ở mức health/readiness. |
| Web | `apps/web/src/main.jsx`, Router, danh sách/tìm phim, trang chi tiết và lịch chiếu, trailer, liên kết chia sẻ. Axios xác lập sẵn nơi tích hợp session. |
| Cấu hình dùng chung | `packages/server/config.js`, `db.js`, `http.js`, `bootstrap.js`. Kiểm tra biến môi trường, Knex pool/TLS, lỗi thống nhất, request ID và graceful shutdown. |
| Hạ tầng | `render.yaml`, `apps/web/vercel.json`, `docker-compose.yml` cho PostgreSQL local, hai SQL ở `database/` và CI kiểm tra build. |

Bản này đủ để deploy hạ tầng và chạy luồng duyệt phim. Các module đăng nhập, quản trị, giữ ghế, thanh toán và soát vé vẫn cần phát triển. Core còn cần nối email vào các luồng nghiệp vụ. Swagger public chỉ liệt kê các endpoint đã có code. Contract đầy đủ và mock giữ ở `contracts/` và `scripts/mock.mjs`.

## Chạy local

Cần Node.js 22.12+ trong dòng 22 và Docker Compose. Chạy từ thư mục gốc:

```bash
cp .env.example .env
docker compose up -d --wait
npm ci
npm run dev:api
```

Nếu cần chạy Payment và Notification, mở hai terminal và chạy `npm run dev:payment` và `npm run dev:notification`. Trước khi khởi động Notification, điền khóa theo runbook email. Core/Payment/Notification dùng cổng 3000/3001/3002, PostgreSQL bind `127.0.0.1:15432`. Backend local kết nối đến database `cinema_local` với ba schema thay vì ba máy chủ. Compose tự nạp schema và seed khi volume còn trống.

Mở terminal frontend:

```bash
cd apps/web
npm ci
npm run dev
```

Vite chuyển tiếp `/api/v1` và `/share` tới Core local. Mở `http://localhost:5173`, hoặc mở Swagger tại `http://localhost:3000/docs/`. Để làm giao diện với fixture tĩnh, chạy `npm run mock` ở gốc và đặt `CORE_DEV_ORIGIN=http://localhost:4010` trong `apps/web/.env`. Trang chia sẻ SSR dùng Core thật. Trailer đầu tiên có URL fixture; đổi thành trailer được phép nhúng lúc chuẩn bị demo.

## Triển khai

### 1. Supabase

- Trong một project Supabase, chạy đủ ba khối của `database/001_init_schema.sql`, sau đó chạy `002_notification_delivery.sql` và `003_supabase_roles.sql` trong cùng thư mục. Bật LOGIN với mật khẩu riêng cho ba role theo runbook. Seed chỉ dùng cho môi trường demo hoặc local.
- Trong Supabase **Connect**, sao chép hostname **Session pooler (5432)** của project và tạo URI theo role của từng dịch vụ. Nếu dùng role giới hạn quyền, cấp `USAGE` trên schema và quyền cần thiết trên bảng. Dùng URI đã được URL-encode đúng mật khẩu.
- `5432` phù hợp mặc định cho Node/Knex chạy thường trực. Với shared transaction pooler `6543`, tránh query pg có `name` và phụ thuộc vào cấu hình phiên. Code dùng tên schema trực tiếp và bỏ session timeout ở mode này. Nếu cần timeout cho `6543`, dùng mặc định cấp role hoặc timeout cục bộ của transaction.

### 2. Render

- Tạo Blueprint từ repo với `render.yaml`, hoặc tạo ba Node Web Service thủ công dùng repo root. Blueprint chọn plan Free cho bản đồ án. Các URL công khai sẽ do Render cấp.
- Điền `DATABASE_URL` **riêng** cho từng dịch vụ theo ba role, điền nhóm biến email cho Notification theo runbook và `WEB_ORIGIN=https://<tên-frontend>.vercel.app` cho Core. Có thể giữ tên `CORE_DATABASE_URL`, `PAYMENT_DATABASE_URL`, `NOTIFICATION_DATABASE_URL` nếu đã cấu hình; tên riêng của service được ưu tiên.
- TLS production mặc định `verify-full`. Nếu cần CA riêng từ endpoint, tạo file CA trên Render rồi đặt `DB_SSL_CA_FILE` trỏ đến file đó. Khi dùng cấu hình TLS này, bỏ tham số `sslmode` hoặc `sslrootcert` khỏi URI.
- Build dùng `npm ci --omit=dev`. Start lần lượt `npm start`, `npm run start:payment`, `npm run start:notification`. Cả ba bind `0.0.0.0` vào biến `PORT` do Render cấp. Nếu `/health` trả 503, kiểm tra URI, SSL, quyền truy cập bảng và phần schema đã chạy khớp dịch vụ.
- Mở `https://<core>.onrender.com/docs/` và kiểm tra `GET /api/v1/movies` trước khi nối frontend.

### 3. Vercel

- Tạo project Vite với **Root Directory** là `apps/web`, Node.js **22.x**. Trong `apps/web/vercel.json`, đổi cả hai hostname `replace-with-core.onrender.com` thành hostname Core thật. Commit thay đổi để Vercel build.
- Frontend mặc định gọi `/api/v1` cùng origin. Giữ rewrite cho `/api/v1` và `/share` trước fallback `/index.html`. Khi Vercel cấp URL production khác URL dự kiến, cập nhật `WEB_ORIGIN` trên Render rồi deploy lại Core.
- Thử URL frontend `/api/v1/movies`, điều hướng vào phim rồi reload URL chi tiết, mở trang chia sẻ và kiểm tra dữ liệu. Biến DB, JWT và khóa liên dịch vụ chỉ đặt ở backend. Dùng `VITE_API_BASE_URL` nếu muốn đổi base URL công khai cho một môi trường cụ thể.

## Kiểm tra mã

```bash
npm test
npm --prefix apps/web run build
```

[Tài liệu Render](https://render.com/docs/blueprint-spec) · [Vercel Vite](https://vercel.com/docs/frameworks/frontend/vite) · [Vercel Rewrites](https://vercel.com/docs/routing/rewrites) · [Supabase Connection Pooler](https://supabase.com/docs/guides/database/connecting-to-postgres)
