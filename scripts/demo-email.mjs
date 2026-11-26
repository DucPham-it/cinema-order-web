import { createPrivateKey, randomUUID } from "node:crypto";
import { readFileSync } from "node:fs";
import { SignJWT } from "jose";

const [mode, suppliedKey] = process.argv.slice(2);
if (!["verify", "ticket"].includes(mode)) {
  process.stderr.write("Usage: npm run demo:email -- verify|ticket [idempotency-key]\n");
  process.exit(2);
}
const {
  CORE_SERVICE_PRIVATE_KEY_FILE, CORE_TO_NOTIFICATION_API_KEY, MAIL_DEMO_RECIPIENT,
  MAIL_ACTION_ORIGIN, NOTIFICATION_BASE_URL,
} = process.env;
if (!CORE_SERVICE_PRIVATE_KEY_FILE || !CORE_TO_NOTIFICATION_API_KEY ||
    !MAIL_DEMO_RECIPIENT || !MAIL_ACTION_ORIGIN || !NOTIFICATION_BASE_URL) {
  throw new Error("Set CORE_SERVICE_PRIVATE_KEY_FILE, CORE_TO_NOTIFICATION_API_KEY, MAIL_DEMO_RECIPIENT, MAIL_ACTION_ORIGIN and NOTIFICATION_BASE_URL");
}
const destination = new URL(NOTIFICATION_BASE_URL);
if (destination.protocol !== "https:" &&
    !(destination.protocol === "http:" && ["localhost", "127.0.0.1", "[::1]"].includes(destination.hostname))) {
  throw new Error("Use HTTPS for Notification outside localhost");
}

const idempotencyKey = suppliedKey ?? `demo-${mode}-${randomUUID()}`;
const suffix = idempotencyKey.slice(-16);
const input = mode === "verify"
  ? { template: "verify_email", data: { actionUrl: new URL("/", MAIL_ACTION_ORIGIN).href } }
  : {
    template: "ticket_issued",
    data: { bookingId: `demo-${suffix}`, bookingCode: `DEMO-${suffix}`,
      tickets: [{ seatLabel: "A1", qrToken: `CINEMA-DEMO:${idempotencyKey}:A1` }] },
  };

// Wake Render and check the database before minting the short-lived token.
const health = await fetch(new URL("/health", destination), {
  redirect: "error",
  signal: AbortSignal.timeout(90_000),
});
if (!health.ok) throw new Error(`Notification health check returned HTTP ${health.status}`);
await health.body?.cancel();

const privateKey = createPrivateKey(readFileSync(CORE_SERVICE_PRIVATE_KEY_FILE));
const token = await new SignJWT({ scope: "notifications:send" })
  .setProtectedHeader({ alg: "EdDSA" })
  .setIssuer(process.env.SERVICE_TOKEN_ISSUER || "cinema-services")
  .setAudience("cinema-notification")
  .setIssuedAt()
  .setExpirationTime("60s")
  .sign(privateKey);
const response = await fetch(`${destination.href.replace(/\/$/, "")}/internal/notifications`, {
  method: "POST",
  redirect: "error",
  signal: AbortSignal.timeout(90_000),
  headers: {
    Authorization: `Bearer ${token}`,
    "X-API-Key": CORE_TO_NOTIFICATION_API_KEY,
    "Idempotency-Key": idempotencyKey,
    "Content-Type": "application/json",
  },
  body: JSON.stringify({ ...input, recipient: MAIL_DEMO_RECIPIENT }),
});
const result = await response.json().catch(() => ({}));
process.stdout.write(JSON.stringify({
  statusCode: response.status, idempotencyKey, data: result.data, error: result.error?.code,
}, null, 2) + "\n");
if (!response.ok || result.data?.status !== "sent") process.exitCode = 1;
