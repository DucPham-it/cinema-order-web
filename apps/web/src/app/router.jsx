import { createBrowserRouter, isRouteErrorResponse, Link, Outlet, useRouteError } from "react-router";
import { loadMovies, loadMovie, MoviePage, MoviesPage } from "../features/catalog/pages.jsx";

function Layout() {
  return (
    <>
      <header><nav className="container"><Link to="/">Cinema</Link></nav></header>
      <main className="container"><Outlet /></main>
    </>
  );
}

function RouteError() {
  const error = useRouteError();
  const missing = isRouteErrorResponse(error) && error.status === 404;
  return (
    <main className="container">
      <h1>{missing ? "Không tìm thấy trang" : "Chưa tải được dữ liệu"}</h1>
      <p>{missing ? "Đường dẫn này không có nội dung." : "Thử tải lại trang sau ít phút."}</p>
      <Link to="/">Về danh sách phim</Link>
    </main>
  );
}

export const router = createBrowserRouter([{
  path: "/",
  Component: Layout,
  ErrorBoundary: RouteError,
  HydrateFallback: () => <main className="container" aria-busy="true">Đang tải phim…</main>,
  children: [
    { index: true, loader: loadMovies, Component: MoviesPage },
    { path: "movies/:movieId", loader: loadMovie, Component: MoviePage },
    { path: "*", loader: () => { throw new Response(null, { status: 404 }); } },
  ],
}]);
