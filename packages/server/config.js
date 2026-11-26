import { z } from "zod";

const origin = z.url({ protocol: /^https?$/ }).transform((value) => new URL(value).origin);
const settings = z.object({
  NODE_ENV: z.enum(["development", "test", "production"]).default("development"),
  PORT: z.coerce.number().int().min(1).max(65535),
  WEB_ORIGIN: origin.optional(),
  DATABASE_URL: z.string().min(1),
  DB_SSL_MODE: z.enum(["disable", "verify-full"]).optional(),
  DB_SSL_CA_FILE: z.string().optional(),
  DB_POOL_MAX: z.coerce.number().int().min(1).max(30).default(3),
  DB_STATEMENT_TIMEOUT_MS: z.coerce.number().int().positive().default(3000),
  LOG_LEVEL: z.enum(["fatal", "error", "warn", "info", "debug", "trace", "silent"]).default("info"),
});

export function readConfig({ portKey, defaultPort, databaseKey, needsOrigin = false }, env = process.env) {
  const parsed = settings.safeParse({
    ...env,
    PORT: env.PORT ?? env[portKey] ?? defaultPort,
    DATABASE_URL: env[databaseKey] ?? env.DATABASE_URL,
    WEB_ORIGIN: needsOrigin ? env.WEB_ORIGIN : undefined,
  });
  if (!parsed.success) {
    const fields = parsed.error.issues.map(({ path }) => path.join("."));
    throw new Error(`Invalid environment variables: ${fields.join(", ")}`);
  }

  const config = parsed.data;
  const production = config.NODE_ENV === "production";
  if (production && needsOrigin && !config.WEB_ORIGIN?.startsWith("https://")) {
    throw new Error("Set WEB_ORIGIN to the HTTPS origin of the Vercel app");
  }
  const sslMode = config.DB_SSL_MODE ?? (production ? "verify-full" : "disable");
  if (production && sslMode !== "verify-full") {
    throw new Error("Set DB_SSL_MODE=verify-full in production");
  }
  const url = URL.parse(config.DATABASE_URL);
  if (!url || !["postgresql:", "postgres:"].includes(url.protocol) || !url.hostname) {
    throw new Error(`Set a PostgreSQL URL in ${databaseKey} or DATABASE_URL`);
  }
  for (const key of ["ssl", "sslmode", "sslcert", "sslkey", "sslrootcert"]) {
    if (url.searchParams.has(key)) {
      throw new Error(`Remove ${key} from the URL and configure TLS through DB_SSL_MODE and DB_SSL_CA_FILE`);
    }
  }

  return {
    port: config.PORT,
    webOrigin: config.WEB_ORIGIN,
    logLevel: config.LOG_LEVEL,
    database: {
      url,
      sslMode,
      caFile: config.DB_SSL_CA_FILE,
      poolMax: config.DB_POOL_MAX,
      statementTimeout: config.DB_STATEMENT_TIMEOUT_MS,
    },
  };
}
