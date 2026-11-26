import assert from "node:assert/strict";
import { test } from "node:test";
import { createMailSender, readMailConfig, renderMail } from "../services/notification/src/modules/jobs/mail.js";

test("Resend receives the idempotency key, recipient and PNG attachment", async () => {
  const config = readMailConfig({
    NODE_ENV: "production",
    MAIL_TRANSPORT: "resend",
    MAIL_FROM: "Cinema <onboarding@resend.dev>",
    MAIL_DEMO_RECIPIENT: "demo@example.test",
    MAIL_ACTION_ORIGIN: "https://cinema.example.test",
    RESEND_API_KEY: "fixture-key",
  });
  const send = createMailSender(config, async (url, options) => {
    assert.equal(url, "https://api.resend.com/emails");
    assert.equal(options.headers["Idempotency-Key"], "cinema/fixture-key");
    assert.equal(options.headers.Authorization, "Bearer fixture-key");
    const payload = JSON.parse(options.body);
    assert.deepEqual(payload.to, ["demo@example.test"]);
    assert.equal(payload.attachments[0].filename, "ve-1.png");
    assert.ok(payload.attachments[0].content.startsWith("iVBORw0KGgo"));
    return Response.json({ id: "test-message" });
  });

  const message = await renderMail({
    template: "ticket_issued",
    recipient: "demo@example.test",
    data: { bookingCode: "DEMO-1", tickets: [{ qrToken: "fixture-ticket", seatLabel: "A1" }] },
  });
  assert.equal(await send(message, "fixture-key"), "test-message");
});
