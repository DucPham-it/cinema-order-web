# Quy ước cấu hình

| Điểm cấu hình | Nơi đặt | Quy ước |
|---|---|---|
| Node backend, lệnh chạy và dependency | `package.json`, `package-lock.json` tại gốc | Một bộ dependency cho ba dịch vụ Express. Cài bằng `npm ci`. |
| React/Vite | `apps/web/package.json`, `apps/web/package-lock.json`, `apps/web/vite.config.js` | Vercel chọn Root Directory là `apps/web`. |
| Biến môi trường backend | `.env.example` tại gốc và Render Environment | `.env.example` là bản mẫu, `.env` chỉ dùng local. Mỗi Render service đặt `DATABASE_URL` phù hợp với role của schema mình dùng. |
| Biến môi trường frontend | `apps/web/.env.example` và Vercel Environment | Chỉ dùng giá trị công khai như `VITE_API_BASE_URL`. Mặc định gọi `/api/v1` cùng origin. |
| Cấu hình dùng chung backend | `packages/server/config.js`, `db.js`, `http.js`, `bootstrap.js` | Khởi động, kiểm tra env, kết nối DB và lỗi dùng chung. Mỗi service giữ entry point và module nghiệp vụ riêng. |
| Triển khai | `render.yaml`, `apps/web/vercel.json` | Blueprint đặt ở gốc repo. Vercel config nằm tại root của app được deploy. |
| Local | `docker-compose.yml`, `database/*.sql` | Compose chạy PostgreSQL local, thêm profile Mailpit khi demo email. SQL tạo schema/migration đánh số; seed chỉ dùng local/demo. |
| API và CI | `contracts/openapi.*.json`, `.github/workflows/verify.yml` | Hợp đồng là đầu vào cho mock và tích hợp. Giữ lockfile cùng CI. |

Backend dùng một project Supabase với ba schema và ba role. Demo email cloud dùng Resend HTTPS. Thứ tự khởi tạo SQL và cấu hình người nhận được ghi trong [runbook cloud](deploy-free-and-email.md).
