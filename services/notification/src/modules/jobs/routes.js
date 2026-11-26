import { createHash, createPublicKey, timingSafeEqual } from "node:crypto";
import { Router } from "express";
import { jwtVerify } from "jose";
import { z } from "zod";
import { AppError, send } from "../../../../../packages/server/http.js";
import { renderMail } from "./mail.js";

const template = z.discriminatedUnion("template", [
  z.object({
    template: z.literal("verify_email"),
    recipient: z.email(),
    data: z.object({ actionUrl: z.url({ protocol: /^https?$/ }).max(2048) }),
  }),
  z.object({
    template: z.literal("reset_password"),
    recipient: z.email(),
    data: z.object({ actionUrl: z.url({ protocol: /^https?$/ }).max(2048) }),
  }),
  z.object({
    template: z.literal("ticket_issued"),
    recipient: z.email(),
    data: z.object({
      bookingId: z.string().min(1).max(128),
      bookingCode: z.string().min(1).max(128),
      tickets: z.array(z.object({
        seatLabel: z.string().min(1).max(40),
        qrToken: z.string().min(1).max(512),
      })).min(1).max(12),
    }),
  }),
]);
const deliveryKey = z.string().regex(/^[a-zA-Z0-9._:-]{1,128}$/);
const hash = value => createHash("sha256").update(value).digest("hex");
const claimSeconds = 120;
const providerReplayHours = 23;

export function createServiceGuard({ serviceKey, corePublicKey, issuer = "cinema-core" }) {
  if (!serviceKey || serviceKey.length < 32) throw new Error("Set a random CORE_TO_NOTIFICATION_API_KEY of at least 32 characters");
  if (!corePublicKey) throw new Error("Set CORE_SERVICE_PUBLIC_KEY");
  const publicKey = createPublicKey(corePublicKey.replaceAll("\\n", "\n"));
  if (publicKey.asymmetricKeyType !== "ed25519") throw new Error("Use an Ed25519 public key for Core");
  const expected = Buffer.from(hash(serviceKey));

  return async (req, _res, next) => {
    const actual = Buffer.from(hash(req.get("X-API-Key") ?? ""));
    const token = /^Bearer ([^ ]+)$/i.exec(req.get("Authorization") ?? "")?.[1];
    if (!timingSafeEqual(actual, expected) || !token) {
      throw new AppError(401, "SERVICE_AUTH_REQUIRED", "Thiếu xác thực dịch vụ");
    }

    let payload;
    try {
      ({ payload } = await jwtVerify(token, publicKey, {
        algorithms: ["EdDSA"], issuer, audience: "cinema-notification",
        requiredClaims: ["iat", "exp"], maxTokenAge: "60s", clockTolerance: 5,
      }));
      if (payload.exp - payload.iat > 60 || payload.exp <= payload.iat) throw new Error("Invalid token lifetime");
    } catch {
      throw new AppError(401, "INVALID_SERVICE_TOKEN", "Token dịch vụ không hợp lệ");
    }
    if (typeof payload.scope !== "string" || !payload.scope.split(" ").includes("notifications:send")) {
      throw new AppError(403, "SERVICE_SCOPE_REQUIRED", "Dịch vụ chưa có quyền gửi email");
    }
    next();
  };
}

export function createNotificationRouter({ db, authorize, sendMail, config }) {
  const router = Router();
  const jobs = client => client.withSchema("cinema_notification").table("notification_jobs");

  router.post("/internal/notifications", authorize, async (req, res) => {
    const idempotencyKey = deliveryKey.parse(req.get("Idempotency-Key"));
    const input = template.parse(req.body);
    input.recipient = input.recipient.toLowerCase();
    if (config.MAIL_DEMO_RECIPIENT && input.recipient !== config.MAIL_DEMO_RECIPIENT.toLowerCase()) {
      throw new AppError(403, "RECIPIENT_NOT_ALLOWED", "Chỉ gửi tới hộp thư demo đã cấu hình");
    }
    if ("actionUrl" in input.data) {
      const action = new URL(input.data.actionUrl);
      if (action.origin !== config.MAIL_ACTION_ORIGIN || action.username || action.password) {
        throw new AppError(422, "ACTION_ORIGIN_MISMATCH", "Liên kết email phải thuộc frontend");
      }
    }

    const requestHash = hash(JSON.stringify(input));
    const claim = await db.transaction(async (trx) => {
      await jobs(trx).insert({
        idempotency_key: idempotencyKey,
        template: input.template,
        recipient: input.recipient,
        data: { requestHash },
        status: "pending",
      }).onConflict("idempotency_key").ignore();

      const row = await jobs(trx).where({ idempotency_key: idempotencyKey }).forUpdate().first();
      if (row.data.requestHash !== requestHash) {
        throw new AppError(409, "IDEMPOTENCY_MISMATCH", "Khóa đã được dùng với yêu cầu khác");
      }
      if (row.status === "sent") return { row, claimed: false };
      if (row.status === "processing" && row.next_attempt_at > new Date()) return { row, claimed: false };
      if (row.attempts >= 3 || Date.now() - row.created_at.getTime() > providerReplayHours * 3_600_000) {
        throw new AppError(409, "DELIVERY_RETRY_EXHAUSTED", "Kiểm tra kết quả gửi trước khi tạo yêu cầu mới");
      }
      const [claimed] = await jobs(trx).where({ id: row.id }).update({
        status: "processing",
        attempts: row.attempts + 1,
        next_attempt_at: trx.raw("now() + (? * interval '1 second')", [claimSeconds]),
      }).returning("*");
      return { row: claimed, claimed: true };
    });

    const { row, claimed } = claim;
    if (!claimed && row.status === "sent") {
      return send(res, 200, { id: row.id, status: "sent", providerMessageId: row.provider_message_id });
    }
    if (!claimed) return send(res, 202, { id: row.id, status: "processing" });

    let providerMessageId;
    try {
      providerMessageId = await sendMail(await renderMail(input), hash(idempotencyKey));
    } catch (error) {
      await jobs(db).where({ id: row.id, status: "processing", attempts: row.attempts }).update({ status: "failed" });
      req.log.warn({ providerStatus: error.providerStatus }, "Notification delivery failed");
      throw new AppError(503, "MAIL_DELIVERY_FAILED", "Gửi email thất bại. Có thể thử lại với cùng yêu cầu và khóa");
    }

    const updated = await jobs(db).where({ id: row.id, status: "processing", attempts: row.attempts }).update({
      status: "sent",
      sent_at: db.fn.now(),
      provider_message_id: providerMessageId,
    });
    if (updated !== 1) return send(res, 202, { id: row.id, status: "processing" });
    return send(res, 200, { id: row.id, status: "sent", providerMessageId }, "Nhà cung cấp đã nhận email");
  });

  return router;
}
