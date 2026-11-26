import nodemailer from "nodemailer";
import QRCode from "qrcode";
import { z } from "zod";

const emailSettings = z.object({
  MAIL_TRANSPORT: z.enum(["smtp", "resend"]),
  MAIL_FROM: z.string().min(1).max(254),
  MAIL_DEMO_RECIPIENT: z.email().optional(),
  MAIL_ACTION_ORIGIN: z.url({ protocol: /^https?$/ }).transform(value => new URL(value).origin),
  RESEND_API_KEY: z.string().optional(),
  SMTP_HOST: z.string().min(1).default("127.0.0.1"),
  SMTP_PORT: z.coerce.number().int().min(1).max(65535).default(1025),
  SMTP_SECURE: z.enum(["false", "true"]).default("false"),
});

export function readMailConfig(env = process.env) {
  const production = env.NODE_ENV === "production";
  const values = emailSettings.safeParse({
    ...env,
    MAIL_TRANSPORT: env.MAIL_TRANSPORT ?? (production ? "resend" : "smtp"),
    MAIL_FROM: env.MAIL_FROM ?? "Cinema <tickets@example.test>",
    MAIL_ACTION_ORIGIN: env.MAIL_ACTION_ORIGIN ?? (production ? undefined : "http://localhost:5173"),
    MAIL_DEMO_RECIPIENT: env.MAIL_DEMO_RECIPIENT || undefined,
  });
  if (!values.success) {
    throw new Error(`Invalid mail settings: ${values.error.issues.map(({ path }) => path.join(".")).join(", ")}`);
  }
  const config = values.data;
  if (production && (config.MAIL_TRANSPORT !== "resend" || !config.MAIL_DEMO_RECIPIENT ||
      !config.MAIL_ACTION_ORIGIN.startsWith("https://"))) {
    throw new Error("Set Resend, an approved demo inbox and an HTTPS action origin in production");
  }
  if (config.MAIL_TRANSPORT === "resend" && !config.RESEND_API_KEY) {
    throw new Error("Set RESEND_API_KEY for Resend");
  }
  return config;
}

export async function renderMail({ template, recipient, data }) {
  if (template === "verify_email" || template === "reset_password") {
    const subject = template === "verify_email" ? "Xác thực email Cinema" : "Đặt lại mật khẩu Cinema";
    return { to: recipient, subject, text: `${subject}\n\nMở liên kết sau để tiếp tục:\n${data.actionUrl}` };
  }

  const attachments = await Promise.all(data.tickets.map(async ({ qrToken }, index) => ({
    filename: `ve-${index + 1}.png`,
    content: await QRCode.toBuffer(qrToken, { width: 320, errorCorrectionLevel: "M" }),
  })));
  const seats = data.tickets.map(({ seatLabel }) => seatLabel).join(", ");
  return {
    to: recipient,
    subject: "Vé điện tử Cinema",
    text: `Mã đặt vé: ${data.bookingCode}\nGhế: ${seats}\nMỗi file PNG đính kèm chứa mã QR cho một ghế.`,
    attachments,
  };
}

export function createMailSender(config, fetchImpl = fetch) {
  if (config.MAIL_TRANSPORT === "resend") {
    return async (message, idempotencyKey) => {
      const { attachments, ...envelope } = message;
      const response = await fetchImpl("https://api.resend.com/emails", {
        method: "POST",
        signal: AbortSignal.timeout(8_000),
        headers: {
          Authorization: `Bearer ${config.RESEND_API_KEY}`,
          "Content-Type": "application/json",
          "Idempotency-Key": `cinema/${idempotencyKey}`,
        },
        body: JSON.stringify({
          ...envelope,
          from: config.MAIL_FROM,
          to: [message.to],
          ...(attachments && {
            attachments: attachments.map(({ filename, content }) => ({ filename, content: content.toString("base64") })),
          }),
        }),
      });
      if (!response.ok) {
        await response.body?.cancel();
        const error = new Error("Email provider rejected the request");
        error.providerStatus = response.status;
        throw error;
      }
      const { id } = await response.json();
      if (typeof id !== "string" || id.length === 0) throw new Error("Email provider did not return a message ID");
      return id;
    };
  }

  const transport = nodemailer.createTransport({
    host: config.SMTP_HOST,
    port: config.SMTP_PORT,
    secure: config.SMTP_SECURE === "true",
    connectionTimeout: 5_000,
    greetingTimeout: 5_000,
    socketTimeout: 8_000,
  });
  return async (message) => {
    const result = await transport.sendMail({ ...message, from: config.MAIL_FROM });
    if (!result.accepted?.length) throw new Error("SMTP did not accept the recipient");
    return result.messageId;
  };
}
