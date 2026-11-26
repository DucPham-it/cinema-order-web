import { startService } from "../../../packages/server/bootstrap.js";
import { createCoreRoutes } from "./app.js";

startService({
  name: "core",
  schema: "cinema_core",
  healthTable: "movies",
  databaseKey: "CORE_DATABASE_URL",
  portKey: "API_PORT",
  defaultPort: 3000,
  needsOrigin: true,
}, createCoreRoutes);
