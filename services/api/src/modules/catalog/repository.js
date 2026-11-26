export function createCatalogRepository(db) {
  const from = (table) => db.withSchema("cinema_core").from(table);

  function moviesQuery({ q, genreId, status } = {}) {
    const query = from("movies").whereNot("movies.status", "archived");
    if (q) {
      const pattern = q.replace(/[\\%_]/g, "\\$&");
      query.whereILike("movies.title", `%${pattern}%`);
    }
    if (status) query.where("movies.status", status);
    if (genreId) {
      const genre = from("movie_genres").select("movie_id").where({ genre_id: genreId });
      query.whereIn("movies.id", genre);
    }
    return query;
  }

  async function paginate(query, columns, sort, page, pageSize) {
    const [{ count }] = await query.clone().count({ count: "*" });
    const items = await query.select(columns).orderBy(sort).limit(pageSize).offset((page - 1) * pageSize);
    return { items, pagination: { page, pageSize, total: Number(count) } };
  }

  function showtimesQuery({ movieId, cinemaId, format, date, fromTime, toTime } = {}) {
    const query = from("showtimes as s")
      .join("auditoriums as a", "a.id", "s.auditorium_id")
      .join("cinemas as c", "c.id", "a.cinema_id")
      .where({ "s.status": "on_sale", "a.status": "active", "c.status": "active" })
      .where("s.starts_at", ">", db.fn.now());
    if (movieId) query.where("s.movie_id", movieId);
    if (cinemaId) query.where("a.cinema_id", cinemaId);
    if (format) query.where("s.format", format);
    if (date) {
      const fromTimeIso = new Date(`${date}T${fromTime ?? "00:00"}:00+07:00`);
      const until = toTime
        ? new Date(`${date}T${toTime}:00+07:00`)
        : new Date(Date.parse(`${date}T00:00:00+07:00`) + 86_400_000);
      query.where("s.starts_at", ">=", fromTimeIso).where("s.starts_at", "<", until);
    }
    return query;
  }

  const showtimeColumns = {
    id: "s.id",
    movieId: "s.movie_id",
    cinemaId: "a.cinema_id",
    auditoriumId: "s.auditorium_id",
    startsAt: "s.starts_at",
    endsAt: "s.ends_at",
    format: "s.format",
    status: "s.status",
  };

  return {
    listMovies(filters) {
      return paginate(moviesQuery(filters), {
        id: "id", title: "title", posterUrl: "poster_url", status: "status",
      }, ["title", "id"], filters.page, filters.pageSize);
    },
    suggestMovies(q, pageSize) {
      return moviesQuery({ q }).select("id", "title").orderBy(["title", "id"]).limit(pageSize);
    },
    async movieById(id) {
      const movie = await moviesQuery().where("movies.id", id).first({
        id: "id", title: "title", slug: "slug", synopsis: "synopsis",
        posterUrl: "poster_url", trailerUrl: "trailer_url", durationMinutes: "duration_minutes",
        ageRating: "age_rating", status: "status",
      });
      if (!movie) return null;

      const genreIds = await from("movie_genres").where({ movie_id: id }).orderBy("genre_id").pluck("genre_id");
      return { ...movie, genreIds };
    },
    listGenres({ page, pageSize }) {
      return paginate(from("genres"), ["id", "name"], ["name", "id"], page, pageSize);
    },
    listCinemas({ page, pageSize }) {
      return paginate(from("cinemas").where({ status: "active" }),
        ["id", "name", "address"], ["name", "id"], page, pageSize);
    },
    async listCombos(cinemaId, { page, pageSize }) {
      const cinema = await from("cinemas").where({ id: cinemaId, status: "active" }).first("id");
      if (!cinema) return null;
      const result = await paginate(from("combos").where({ cinema_id: cinemaId, active: true }),
        { id: "id", name: "name", priceVnd: "price_vnd" }, ["name", "id"], page, pageSize);
      result.items = result.items.map(({ priceVnd, ...combo }) => ({ ...combo, priceVnd: Number(priceVnd) }));
      return result;
    },
    listShowtimes(filters) {
      return paginate(showtimesQuery(filters), showtimeColumns, ["s.starts_at", "s.id"], filters.page, filters.pageSize);
    },
    showtimeById(id) {
      return showtimesQuery().where("s.id", id).first(showtimeColumns);
    },
    async showtimeSeats(showtime) {
      const rows = await from("showtime_seats as stock")
        .join("seats as seat", "seat.id", "stock.seat_id")
        .leftJoin("price_rules as price", function () {
          this.on("price.seat_kind", "=", "seat.kind")
            .andOn("price.cinema_id", "=", db.raw("?", [showtime.cinemaId]))
            .andOn("price.format", "=", db.raw("?", [showtime.format]))
            .andOn("price.active", "=", db.raw("?", [true]));
        })
        .where("stock.showtime_id", showtime.id)
        .orderBy(["seat.row_label", "seat.seat_number"])
        .select({
          id: "seat.id", kind: "seat.kind", x: "seat.x", y: "seat.y", priceVnd: "price.amount_vnd",
          label: db.raw("concat(??, ??)", ["seat.row_label", "seat.seat_number"]),
          status: db.raw("case when ?? = ? and ?? <= now() then ? else ?? end",
            ["stock.status", "held", "stock.hold_expires_at", "available", "stock.status"]),
        });

      return rows.map(({ priceVnd, ...seat }) => ({ ...seat, priceVnd: priceVnd === null ? null : Number(priceVnd) }));
    },
  };
}
