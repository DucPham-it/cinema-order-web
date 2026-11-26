import axios from "axios";

const baseURL = import.meta.env.VITE_API_BASE_URL || "/api/v1";
export const api = axios.create({ baseURL, timeout: 8000 });
const sessionApi = axios.create({ baseURL, withCredentials: true, timeout: 8000 });

let accessToken = null;
let refreshInFlight = null;
let sessionRevision = 0;

function setAccessToken(token) {
  accessToken = token;
  sessionRevision += 1;
}

export async function login(credentials) {
  const { data } = await sessionApi.post("/auth/login", credentials);
  setAccessToken(data.data.accessToken);
  return data.data.user;
}

export async function logout() {
  if (refreshInFlight) await refreshInFlight.catch(() => {});
  setAccessToken(null);
  await sessionApi.post("/auth/logout");
}

export function restoreSession() {
  if (!refreshInFlight) {
    const revision = sessionRevision;
    refreshInFlight = sessionApi.post("/auth/refresh")
      .then(({ data }) => {
        if (revision === sessionRevision) setAccessToken(data.data.accessToken);
        return accessToken;
      })
      .catch((error) => {
        if (revision === sessionRevision) setAccessToken(null);
        throw error;
      })
      .finally(() => { refreshInFlight = null; });
  }
  return refreshInFlight;
}

api.interceptors.request.use((config) => {
  if (accessToken && !config.skipAuth) {
    config.headers.set("Authorization", `Bearer ${accessToken}`);
  }
  config.sessionRevision = sessionRevision;
  return config;
});

api.interceptors.response.use(undefined, async (error) => {
  const config = error.config;
  if (!config || config.skipAuth || config.retried || error.response?.status !== 401) {
    throw error;
  }

  config.retried = true;
  const token = config.sessionRevision !== sessionRevision ? accessToken : await restoreSession();
  if (!token) throw error;

  config.headers.set("Authorization", `Bearer ${token}`);
  return api.request(config);
});
