import { startService } from "../../../packages/server/bootstrap.js";

startService({
  name: "payment",
  schema: "cinema_payment",
  healthTable: "payments",
  databaseKey: "PAYMENT_DATABASE_URL",
  portKey: "PAYMENT_PORT",
  defaultPort: 3001,
});
