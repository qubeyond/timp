import { useEffect, useState } from "react";
import { Link, useNavigate, useParams } from "react-router-dom";
import { incidentsApi } from "../api/incidents.js";
import Spinner from "../components/Spinner.jsx";
import ErrorBanner from "../components/ErrorBanner.jsx";

export default function Detail() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [incident, setIncident] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    setLoading(true);
    setError("");
    incidentsApi
      .get(id)
      .then(setIncident)
      .catch((e) => setError(e.message))
      .finally(() => setLoading(false));
  }, [id]);

  function handleDelete() {
    if (!window.confirm("Удалить инцидент?")) return;
    incidentsApi
      .remove(id)
      .then(() => navigate("/"))
      .catch((e) => setError(e.message));
  }

  if (loading) return <Spinner />;
  if (error) return <ErrorBanner message={error} />;
  if (!incident) return null;

  return (
    <div className="detail-card">
      <Link to="/" className="back-link">
        ← К списку
      </Link>
      <h1>{incident.title}</h1>
      <dl>
        <dt>Сервис</dt>
        <dd>{incident.service}</dd>
        <dt>Источник сигнала</dt>
        <dd>{incident.source}</dd>
        <dt>Степень угрозы</dt>
        <dd>{incident.threat_level} / 10</dd>
        <dt>Статус</dt>
        <dd>{incident.status}</dd>
        <dt>Дата и время</dt>
        <dd>{new Date(incident.occurred_at).toLocaleString("ru-RU")}</dd>
        <dt>Ответственный</dt>
        <dd>{incident.responsible}</dd>
        <dt>Описание</dt>
        <dd>{incident.description || "—"}</dd>
      </dl>
      <div className="detail-actions">
        <Link to={`/edit/${incident.id}`} className="button">
          Изменить
        </Link>
        <button type="button" className="button danger" onClick={handleDelete}>
          Удалить
        </button>
      </div>
    </div>
  );
}
