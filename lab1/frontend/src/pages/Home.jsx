import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { incidentsApi } from "../api/incidents.js";
import Spinner from "../components/Spinner.jsx";
import ErrorBanner from "../components/ErrorBanner.jsx";

const STATUS_CLASS = {
  "Новый": "status-new",
  "В работе": "status-progress",
  "Завершён": "status-done",
  "Закрыт": "status-closed",
};

function formatDate(iso) {
  return new Date(iso).toLocaleString("ru-RU");
}

export default function Home() {
  const [incidents, setIncidents] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [deletingId, setDeletingId] = useState(null);

  function load() {
    setLoading(true);
    setError("");
    incidentsApi
      .list()
      .then(setIncidents)
      .catch((e) => setError(e.message))
      .finally(() => setLoading(false));
  }

  useEffect(load, []);

  function handleDelete(id) {
    if (!window.confirm("Удалить инцидент?")) return;
    setDeletingId(id);
    incidentsApi
      .remove(id)
      .then(() => setIncidents((prev) => prev.filter((i) => i.id !== id)))
      .catch((e) => setError(e.message))
      .finally(() => setDeletingId(null));
  }

  if (loading) return <Spinner />;

  return (
    <div>
      <h1>Список инцидентов</h1>
      <ErrorBanner message={error} />

      {incidents.length === 0 ? (
        <p className="empty">Инцидентов пока нет. Добавьте первый.</p>
      ) : (
        <table className="incidents-table">
          <thead>
            <tr>
              <th>Заголовок</th>
              <th>Сервис</th>
              <th>Угроза</th>
              <th>Статус</th>
              <th>Дата</th>
              <th>Ответственный</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {incidents.map((i) => (
              <tr key={i.id}>
                <td>
                  <Link to={`/detail/${i.id}`}>{i.title}</Link>
                </td>
                <td>{i.service}</td>
                <td>{i.threat_level}</td>
                <td>
                  <span className={`status-badge ${STATUS_CLASS[i.status] ?? ""}`}>{i.status}</span>
                </td>
                <td>{formatDate(i.occurred_at)}</td>
                <td>{i.responsible}</td>
                <td className="row-actions">
                  <Link to={`/edit/${i.id}`}>Изменить</Link>
                  <button
                    type="button"
                    className="link-button danger"
                    disabled={deletingId === i.id}
                    onClick={() => handleDelete(i.id)}
                  >
                    {deletingId === i.id ? "Удаление…" : "Удалить"}
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </div>
  );
}
