import { readFileSync } from "node:fs";
import swaggerUi from "swagger-ui-express";
import { createCatalogRepository } from "./modules/catalog/repository.js";
import { catalogPaths, createCatalogRouter, createShareRouter } from "./modules/catalog/routes.js";

const contract = JSON.parse(readFileSync(new URL("../../../contracts/openapi.core.json", import.meta.url), "utf8"));

const liveSpec = {
  ...contract,
  info: { ...contract.info, description: "Các API danh mục và lịch chiếu có trong starter." },
  servers: [{ url: "/api/v1" }],
  paths: Object.fromEntries(catalogPaths.map((path) => [path, contract.paths[path]])),
};

export function createCoreRoutes({ db, config }) {
  const catalog = createCatalogRepository(db);
  const pageRouter = createShareRouter(catalog, config.webOrigin);
  pageRouter.get("/openapi.json", (_req, res) => res.json(liveSpec));
  pageRouter.use("/docs", swaggerUi.serve, swaggerUi.setup(liveSpec, {
    swaggerOptions: { validatorUrl: null, supportedSubmitMethods: ["get"] },
  }));

  return { apiRouter: createCatalogRouter(catalog), pageRouter };
}
