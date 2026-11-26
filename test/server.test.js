import assert from "node:assert/strict";
import { once } from "node:events";
import { test } from "node:test";
import { readConfig } from "../packages/server/config.js";
import { createApp } from "../packages/server/http.js";

const settings = {
  portKey: "API_PORT",
  defaultPort: 3000,
  databaseKey: "CORE_DATABASE_URL",
  needsOrigin: true,
};

test("production configuration validates TLS and supports the service-local DATABASE_URL", () => {
  const databaseUrl = "postgresql://role.ref:demo@pooler.example.test:5432/postgres";
  const env = {
    NODE_ENV: "production",
    PORT: "10000",
    DATABASE_URL: databaseUrl,
    WEB_ORIGIN: "https://cinema.example.test",
  };

  const config = readConfig(settings, env);
  assert.equal(config.port, 10000);
  assert.equal(config.database.url.href, databaseUrl);
  assert.equal(config.database.sslMode, "verify-full");
  assert.throws(() => readConfig(settings, { ...env, DB_SSL_MODE: "disable" }), /verify-full/);
  assert.throws(() => readConfig(settings, { ...env, WEB_ORIGIN: "" }), /WEB_ORIGIN/);
  assert.throws(() => readConfig(settings, { ...env, DATABASE_URL: databaseUrl + "?sslmode=require" }), /remove sslmode/i);
});

test("readiness failure reports 503 with a request ID and keeps DB details private", async (t) => {
  let available = true;
  const app = createApp({
    serviceName: "test",
    logLevel: "silent",
    probe() {
      if (!available) throw new Error("database driver detail");
    },
  });
  const server = app.listen(0, "127.0.0.1");
  t.after(() => new Promise((resolve, reject) => server.close(error => error ? reject(error) : resolve())));
  await once(server, "listening");
  const baseUrl = `http://127.0.0.1:${server.address().port}`;

  const ready = await fetch(baseUrl + "/health");
  assert.equal(ready.status, 200);
  assert.equal((await ready.json()).data.database, "ready");
  available = false;

  const failed = await fetch(baseUrl + "/health");
  assert.equal(failed.status, 503);
  const body = await failed.json();
  assert.equal(body.error.code, "DATABASE_UNAVAILABLE");
  assert.equal(body.requestId, failed.headers.get("x-request-id"));
  assert.ok(!JSON.stringify(body).includes("database driver detail"));

  const unknown = await fetch(baseUrl + "/api/v1/unimplemented");
  assert.equal(unknown.status, 404);
  assert.equal((await unknown.json()).error.code, "NOT_FOUND");
});
