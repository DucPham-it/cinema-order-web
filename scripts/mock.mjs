import { readFileSync } from "node:fs";
import { createServer } from "node:http";

const basePath = "/api/v1";
const allowedOrigin = process.env.WEB_ORIGIN ?? "http://localhost:5173";
const services = { core: 4010, payment: 4011, notification: 4012 };

function loadRoutes(service) {
  const contract = new URL(`../contracts/openapi.${service}.json`, import.meta.url);
  const { paths } = JSON.parse(readFileSync(contract, "utf8"));

  return Object.entries(paths).flatMap(([path, methods]) => {
    const parts = path.split("/");
    const pattern = parts.map((part) => {
      if (part.startsWith("{")) return "[^/]+";
      return part.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
    });
    const staticSegments = parts.filter((part) => part && !part.startsWith("{")).length;
    const matcher = new RegExp(`^${basePath}${pattern.join("/")}/?$`);

    return Object.entries(methods).map(([method, operation]) => ({
      method: method.toUpperCase(),
      matcher,
      staticSegments,
      responses: operation.responses,
    }));
  }).sort((left, right) => right.staticSegments - left.staticSegments);
}

for (const [service, port] of Object.entries(services)) {
  const routes = loadRoutes(service);
  const server = createServer((req, res) => {
    const url = new URL(req.url, `http://localhost:${port}`);
    if (req.headers.origin === allowedOrigin) {
      res.setHeader("Access-Control-Allow-Origin", allowedOrigin);
      res.setHeader("Access-Control-Allow-Credentials", "true");
      res.setHeader("Vary", "Origin");
    }
    res.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
    res.setHeader("Access-Control-Allow-Headers", [
      "Content-Type", "Authorization", "Idempotency-Key", "X-Hold-Token", "X-Booking-Code",
      "X-API-Key", "X-Webhook-Timestamp", "X-Webhook-Signature",
    ].join(", "));
    res.setHeader("Cache-Control", "no-store");
    req.resume();
    if (req.method === "OPTIONS") return res.writeHead(204).end();

    const route = routes.find(({ method, matcher }) => req.method === method && matcher.test(url.pathname));
    const mockStatus = url.searchParams.get("__status");
    const defaultStatus = route && Object.keys(route.responses).find((code) => code.startsWith("2"));
    const status = defaultStatus && route.responses[mockStatus] ? mockStatus : defaultStatus;
    const example = route?.responses[status]?.content["application/json"]?.example;
    res.setHeader("Content-Type", "application/json; charset=utf-8");

    if (!example) {
      res.writeHead(404).end(JSON.stringify({
        success: false, statusCode: 404, message: "Không tìm thấy endpoint mock",
        error: { code: "NOT_FOUND", details: [] }, requestId: "mock",
      }));
      return;
    }

    const cookieExample = route.responses[status].headers?.["Set-Cookie"]?.example;
    if (cookieExample) res.setHeader("Set-Cookie", cookieExample);
    res.writeHead(Number(status)).end(JSON.stringify(example));
  });
  server.listen(port, () => process.stdout.write(`Mock ${service}: http://localhost:${port}${basePath}\n`));
}
