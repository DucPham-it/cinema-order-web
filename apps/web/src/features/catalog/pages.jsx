import { useState } from "react";
import { Form, Link, useLoaderData, useNavigation } from "react-router";
import { api } from "../../api/client.js";

async function read(path, { signal, params } = {}) {
  try {
    const { data } = await api.get(path, { signal, params, skipAuth: true, timeout: 20_000 });
    return data.data;
  } catch (error) {
    if (error.response?.status === 404) throw new Response(null, { status: 404 });
    throw error;
  }
}

export async function loadMovies({ request }) {
  const query = new URL(request.url).searchParams;
  const q = (query.get("q") ?? "").trim();
  const page = Number(query.get("page")) || 1;
  const data = await read("/movies", { signal: request.signal, params: { q, page } });
  return { ...data, q };
}

export async function loadMovie({ request, params: { movieId } }) {
  const [movie, showtimes] = await Promise.all([
    read(`/movies/${encodeURIComponent(movieId)}`, { signal: request.signal }),
    read("/showtimes", { signal: request.signal, params: { movieId } }),
  ]);
  return { movie, showtimes: showtimes.items };
}

function resultsHref(q, page) {
  const query = new URLSearchParams({ page });
  if (q) query.set("q", q);
  return `/?${query}`;
}

export function MoviesPage() {
  const { items, pagination, q } = useLoaderData();
  const navigation = useNavigation();
  const pages = Math.ceil(pagination.total / pagination.pageSize);

  return (
    <>
      <h1>Phim</h1>
      <Form className="search" aria-label="Tìm phim">
        <label htmlFor="movie-search">Tên phim</label>
        <input id="movie-search" key={q} name="q" type="search" defaultValue={q} maxLength={100} />
        <button type="submit">Tìm phim</button>
      </Form>
      <section aria-label="Kết quả tìm phim" aria-busy={navigation.state !== "idle"}>
        {items.length ? (
          <ul className="movie-grid">
            {items.map((movie) => (
              <li key={movie.id}>
                {movie.posterUrl && <img src={movie.posterUrl} alt="" loading="lazy" width="160" height="230" />}
                <h2><Link to={`/movies/${movie.id}`}>{movie.title}</Link></h2>
              </li>
            ))}
          </ul>
        ) : <p>Không có phim phù hợp.</p>}
      </section>
      {pages > 1 && (
        <nav className="pager" aria-label="Phân trang">
          {pagination.page > 1 && <Link to={resultsHref(q, pagination.page - 1)}>Trang trước</Link>}
          <span>Trang {pagination.page}/{pages}</span>
          {pagination.page < pages && <Link to={resultsHref(q, pagination.page + 1)}>Trang sau</Link>}
        </nav>
      )}
    </>
  );
}

const showtimeFormat = new Intl.DateTimeFormat("vi-VN", {
  dateStyle: "medium", timeStyle: "short", timeZone: "Asia/Ho_Chi_Minh",
});

function Trailer({ title, url }) {
  const [open, setOpen] = useState(false);
  const id = /^https:\/\/www\.youtube\.com\/watch\?v=([A-Za-z0-9_-]{11})$/.exec(url ?? "")?.[1];
  if (!id) return null;

  return (
    <section aria-label="Trailer">
      <button type="button" aria-expanded={open} onClick={() => setOpen(!open)}>
        {open ? "Đóng trailer" : "Xem trailer"}
      </button>
      {open && (
        <>
          <iframe className="trailer" title={`Trailer ${title}`} allowFullScreen
            src={`https://www.youtube-nocookie.com/embed/${id}`} />
          <p><a href={url} target="_blank" rel="noreferrer">Mở trên YouTube</a></p>
        </>
      )}
    </section>
  );
}

export function MoviePage() {
  const { movie, showtimes } = useLoaderData();
  return (
    <>
      <Link to="/">← Danh sách phim</Link>
      <h1>{movie.title}</h1>
      <p>{movie.durationMinutes} phút {movie.ageRating && `· ${movie.ageRating}`}</p>
      {movie.synopsis && <p>{movie.synopsis}</p>}
      <Trailer key={movie.id} title={movie.title} url={movie.trailerUrl} />
      <h2>Suất chiếu mở bán</h2>
      {showtimes.length ? (
        <ul className="showtimes">
          {showtimes.map(({ id, startsAt, format }) => (
            <li key={id}><time dateTime={startsAt}>{showtimeFormat.format(new Date(startsAt))}</time> · {format}</li>
          ))}
        </ul>
      ) : <p>Chưa có suất chiếu mở bán.</p>}
      <a href={`/share/movies/${movie.id}`}>Trang chia sẻ phim</a>
    </>
  );
}
