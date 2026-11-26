import { Router } from "express";
import { z } from "zod";
import { AppError, send } from "../../../../../packages/server/http.js";

const id = z.guid();
const page = z.object({
  page: z.coerce.number().int().min(1).max(1_000_000).default(1),
  pageSize: z.coerce.number().int().min(1).max(100).default(20),
});
const searchTerm = z.string().trim().max(100);
const movieFilters = page.extend({
  q: searchTerm.optional(),
  genreId: id.optional(),
  status: z.enum(["coming_soon", "now_showing"]).optional(),
});
const time = z.string().regex(/^(?:[01]\d|2[0-3]):[0-5]\d$/);
const showtimeFilters = page.extend({
  movieId: id.optional(),
  cinemaId: id.optional(),
  date: z.iso.date().optional(),
  format: z.enum(["2D", "3D", "IMAX"]).optional(),
  fromTime: time.optional(),
  toTime: time.optional(),
}).refine(({ date, fromTime, toTime }) => date || (!fromTime && !toTime), { path: ["date"] })
  .refine(({ fromTime, toTime }) => !fromTime || !toTime || fromTime < toTime, { path: ["toTime"] });
const suggestions = z.object({
  q: searchTerm.min(1),
  pageSize: z.coerce.number().int().min(1).max(20).default(5),
});

export const catalogPaths = [
  "/movies", "/movies/suggestions", "/movies/{movieId}", "/genres", "/cinemas",
  "/cinemas/{cinemaId}/combos", "/showtimes", "/showtimes/{showtimeId}", "/showtimes/{showtimeId}/seats",
];

function requireResource(resource) {
  if (!resource) throw new AppError(404, "NOT_FOUND", "Không tìm thấy tài nguyên");
  return resource;
}

export function createCatalogRouter(catalog) {
  const router = Router();

  router.get("/movies", async (req, res) => send(res, 200,
    await catalog.listMovies(movieFilters.parse(req.query))));
  router.get("/movies/suggestions", async (req, res) => {
    const { q, pageSize } = suggestions.parse(req.query);
    return send(res, 200, { items: await catalog.suggestMovies(q, pageSize) });
  });
  router.get("/movies/:movieId", async (req, res) => send(res, 200,
    requireResource(await catalog.movieById(id.parse(req.params.movieId)))));
  router.get("/genres", async (req, res) => send(res, 200,
    await catalog.listGenres(page.parse(req.query))));
  router.get("/cinemas", async (req, res) => send(res, 200,
    await catalog.listCinemas(page.parse(req.query))));
  router.get("/cinemas/:cinemaId/combos", async (req, res) => send(res, 200,
    requireResource(await catalog.listCombos(id.parse(req.params.cinemaId), page.parse(req.query)))));
  router.get("/showtimes", async (req, res) => send(res, 200,
    await catalog.listShowtimes(showtimeFilters.parse(req.query))));
  router.get("/showtimes/:showtimeId", async (req, res) => send(res, 200,
    requireResource(await catalog.showtimeById(id.parse(req.params.showtimeId)))));
  router.get("/showtimes/:showtimeId/seats", async (req, res) => {
    const showtime = requireResource(await catalog.showtimeById(id.parse(req.params.showtimeId)));
    return send(res, 200, { showtimeId: showtime.id, seats: await catalog.showtimeSeats(showtime) });
  });

  return router;
}

function escapeHtml(text) {
  const entities = { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" };
  return String(text).replace(/[&<>"']/g, (character) => entities[character]);
}

export function createShareRouter(catalog, webOrigin) {
  const router = Router();
  router.get("/share/movies/:movieId", async (req, res) => {
    const movie = requireResource(await catalog.movieById(id.parse(req.params.movieId)));
    const title = escapeHtml(movie.title);
    const synopsis = escapeHtml(movie.synopsis);
    const href = escapeHtml(`${webOrigin ?? "http://localhost:5173"}/movies/${movie.id}`);

    return res.type("html").send(`<!doctype html>
<html lang="vi">
<head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>${title}</title><meta name="description" content="${synopsis}">
<meta property="og:title" content="${title}"><meta property="og:description" content="${synopsis}">
</head><body><main><h1>${title}</h1><p>${synopsis}</p><a href="${href}">Xem phim và lịch chiếu</a></main></body></html>`);
  });
  return router;
}
