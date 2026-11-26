import { readFileSync } from "node:fs";
import { createMailSender, readMailConfig } from "./modules/jobs/mail.js";
import { createNotificationRouter, createServiceGuard } from "./modules/jobs/routes.js";
import { startService } from "../../../packages/server/bootstrap.js";

startService({
  name: "notification",
  schema: "cinema_notification",
  healthTable: "notification_jobs",
  databaseKey: "NOTIFICATION_DATABASE_URL",
  portKey: "NOTIFICATION_PORT",
  defaultPort: 3002,
}, ({ db }) => {
  const config = readMailConfig();
  const publicKeyFile = process.env.CORE_SERVICE_PUBLIC_KEY_FILE;
  const authorize = createServiceGuard({
    serviceKey: process.env.CORE_TO_NOTIFICATION_API_KEY,
    corePublicKey: process.env.CORE_SERVICE_PUBLIC_KEY || (publicKeyFile && readFileSync(publicKeyFile, "utf8")),
    issuer: process.env.SERVICE_TOKEN_ISSUER || "cinema-services",
  });
  return { apiRouter: createNotificationRouter({ db, authorize, config, sendMail: createMailSender(config) }) };
});
