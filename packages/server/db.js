import { readFileSync } from "node:fs";
import knex from "knex";

export function openDatabase({ url, sslMode, caFile, poolMax, statementTimeout }) {
  const transactionPooler = url.port === "6543";
  const ssl = sslMode === "verify-full"
    ? { rejectUnauthorized: true, ...(caFile ? { ca: readFileSync(caFile, "utf8") } : {}) }
    : false;

  return knex({
    client: "pg",
    connection: {
      connectionString: url.href,
      ssl,
      connectionTimeoutMillis: 2500,
      keepAlive: true,
      // Supavisor transaction mode does not preserve session settings.
      ...(sslMode === "disable" && !transactionPooler ? { statement_timeout: statementTimeout } : {}),
    },
    pool: {
      min: 0,
      max: poolMax,
      idleTimeoutMillis: 30_000,
      ...(!transactionPooler && sslMode !== "disable" ? {
        afterCreate(connection, done) {
          connection.query("SELECT set_config('statement_timeout', $1, false)",
            [String(statementTimeout)], (error) => done(error, connection));
        },
      } : {}),
    },
    acquireConnectionTimeout: 3000,
  });
}

export function databaseProbe(db, schema, table) {
  return () => db.withSchema(schema).from(table).select("id").limit(1).timeout(4000);
}
