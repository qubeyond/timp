import axios from "axios";

const BASE_URL = import.meta.env.VITE_API_URL ?? "http://localhost:8000";

const api = axios.create({
  baseURL: BASE_URL,
  headers: { "Content-Type": "application/json" },
});

function unwrap(promise) {
  return promise
    .then((response) => response.data)
    .catch((error) => {
      if (error.response) {
        const { status, data } = error.response;
        const detail =
          typeof data?.detail === "string"
            ? data.detail
            : Array.isArray(data?.detail)
              ? data.detail.map((e) => e.msg).join("; ")
              : "";
        throw new Error(`Ошибка ${status}${detail ? `: ${detail}` : ""}`);
      }
      if (error.request) {
        throw new Error("Сервер недоступен. Проверьте, запущен ли backend на порту 8000.");
      }
      throw new Error(error.message || "Неизвестная ошибка запроса");
    });
}

export const incidentsApi = {
  list: () => unwrap(api.get("/incidents")),
  get: (id) => unwrap(api.get(`/incidents/${id}`)),
  create: (data) => unwrap(api.post("/incidents", data)),
  update: (id, data) => unwrap(api.put(`/incidents/${id}`, data)),
  remove: (id) => unwrap(api.delete(`/incidents/${id}`)),
};
