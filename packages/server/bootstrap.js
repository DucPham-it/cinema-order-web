import { readConfig } from "./config.js";
import { databaseProbe, openDatabase } from "./db.js";
import { createApp, listen } from "./http.js";

export function startService(settings, createRoutes = () => ({})) {
  const config = readConfig(settings);
  const db = openDatabase(config.database);
  const app = createApp({
    serviceName: settings.name,
    probe: databaseProbe(db, settings.schema, settings.healthTable),
    webOrigin: config.webOrigin,
    logLevel: config.logLevel,
    ...createRoutes({ db, config }),
  });
  return listen(app, db, config.port);
}
