import { randomUUID } from "node:crypto";
import cors from "cors";
import express from "express";
import helmet from "helmet";
import pinoHttp from "pino-http";
import { ZodError } from "zod";

export class AppError extends Error {
  constructor(status, code, message, details = []) {
    super(message);
    this.status = status;
    this.code = code;
    this.details = details;
  }
}

export function send(res, status, data, message = "OK") {
  return res.status(status).json({ success: true, statusCode: status, message, data });
}

function errorHandler(error, req, res, next) {
  if (res.headersSent) return next(error);

  let failure = error;
  if (error instanceof ZodError) {
    failure = new AppError(422, "VALIDATION_ERROR", "Dữ liệu không hợp lệ", error.issues.map(
      ({ path, code }) => ({ field: path.join("."), code }),
    ));
  } else if (error.type === "entity.parse.failed") {
    failure = new AppError(400, "INVALID_JSON", "JSON không hợp lệ");
  } else if (error.type === "entity.too.large") {
    failure = new AppError(413, "BODY_TOO_LARGE", "Nội dung gửi lên quá lớn");
  } else if (error instanceof URIError) {
    failure = new AppError(400, "INVALID_PATH", "Đường dẫn không hợp lệ");
  }

  if (!(failure instanceof AppError)) {
    req.log.error({ errorType: error.name, errorCode: error.code }, "Unhandled request error");
    failure = new AppError(500, "INTERNAL_ERROR", "Lỗi hệ thống");
  }

  return res.status(failure.status).json({
    success: false,
    statusCode: failure.status,
    message: failure.message,
    error: { code: failure.code, details: failure.details },
    requestId: req.id,
  });
}

export function createApp({ serviceName, probe, apiRouter, pageRouter, webOrigin, logLevel }) {
  const app = express();
  app.disable("x-powered-by");
  app.use(pinoHttp({
    genReqId: () => randomUUID(),
    serializers: {
      req: ({ id, method }) => ({ id, method }),
      res: ({ statusCode }) => ({ statusCode }),
      err: ({ type, code }) => ({ type, code }),
    },
    level: logLevel ?? "info",
  }));
  app.use((req, res, next) => {
    res.set("X-Request-Id", req.id);
    res.set("Cache-Control", "no-store");
    next();
  });
  app.use(helmet());
  if (webOrigin) app.use(cors({ origin: webOrigin, credentials: true }));

  app.get("/", (_req, res) => send(res, 200, { service: serviceName, health: "/health" }));
  app.get("/health", async (req, res) => {
    try {
      await probe();
    } catch (error) {
      req.log.warn({ errorType: error.name, errorCode: error.code }, "Database health check failed");
      throw new AppError(503, "DATABASE_UNAVAILABLE", "Cơ sở dữ liệu chưa sẵn sàng");
    }
    return send(res, 200, { service: serviceName, database: "ready" });
  });

  if (pageRouter) app.use(pageRouter);
  // Signed webhook routes belong before the JSON parser.
  if (apiRouter) app.use("/api/v1", express.json({ limit: "100kb" }), apiRouter);
  app.use((_req, _res, next) => next(new AppError(404, "NOT_FOUND", "Không tìm thấy tài nguyên")));
  app.use(errorHandler);
  return app;
}

export function listen(app, db, port) {
  const server = app.listen(port, "0.0.0.0", () => {
    process.stdout.write(`Listening on port ${port}\n`);
  });
  server.once("error", (error) => {
    process.stderr.write(`HTTP server failed: ${error.code ?? error.name}\n`);
    process.exitCode = 1;
    db.destroy().catch(() => {});
  });

  function shutdown() {
    const deadline = setTimeout(() => process.exit(1), 12_000);
    deadline.unref();
    server.close(async (error) => {
      try {
        await db.destroy();
        if (error) process.exitCode = 1;
      } catch {
        process.exitCode = 1;
      } finally {
        clearTimeout(deadline);
      }
    });
  }

  process.once("SIGTERM", shutdown);
  process.once("SIGINT", shutdown);
  return server;
}
