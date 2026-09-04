import { useEffect, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import { incidentsApi } from "../api/incidents.js";
import Spinner from "../components/Spinner.jsx";
import ErrorBanner from "../components/ErrorBanner.jsx";

const STATUSES = ["Новый", "В работе", "Завершён", "Закрыт"];

const EMPTY = {
  title: "",
  service: "",
  source: "",
  threat_level: 5,
  status: "Новый",
  occurred_at: "",
  responsible: "",
  description: "",
};

function toDatetimeLocal(iso) {
  if (!iso) return "";
  const d = new Date(iso);
  const pad = (n) => String(n).padStart(2, "0");
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}T${pad(d.getHours())}:${pad(d.getMinutes())}`;
}

function validate(values) {
  const errors = {};
  if (values.title.trim().length < 3) errors.title = "Минимум 3 символа";
  if (values.service.trim().length < 2) errors.service = "Минимум 2 символа";
  if (values.source.trim().length < 2) errors.source = "Минимум 2 символа";
  const level = Number(values.threat_level);
  if (!Number.isInteger(level) || level < 1 || level > 10) {
    errors.threat_level = "Целое число от 1 до 10";
  }
  if (!values.occurred_at) errors.occurred_at = "Укажите дату и время";
  if (values.responsible.trim().length < 2) errors.responsible = "Минимум 2 символа";
  return errors;
}

export default function IncidentForm({ mode }) {
  const { id } = useParams();
  const navigate = useNavigate();
  const isEdit = mode === "edit";

  const [values, setValues] = useState(EMPTY);
  const [errors, setErrors] = useState({});
  const [loading, setLoading] = useState(isEdit);
  const [submitting, setSubmitting] = useState(false);
  const [serverError, setServerError] = useState("");

  useEffect(() => {
    if (!isEdit) return;
    setLoading(true);
    incidentsApi
      .get(id)
      .then((incident) =>
        setValues({
          ...incident,
          occurred_at: toDatetimeLocal(incident.occurred_at),
          description: incident.description ?? "",
        }),
      )
      .catch((e) => setServerError(e.message))
      .finally(() => setLoading(false));
  }, [id, isEdit]);

  function handleChange(field, value) {
    setValues((prev) => ({ ...prev, [field]: value }));
  }

  function handleSubmit(event) {
    event.preventDefault();
    const validationErrors = validate(values);
    setErrors(validationErrors);
    if (Object.keys(validationErrors).length > 0) return;

    setServerError("");
    setSubmitting(true);

    const payload = {
      ...values,
      threat_level: Number(values.threat_level),
      occurred_at: new Date(values.occurred_at).toISOString(),
      description: values.description || null,
    };

    const request = isEdit ? incidentsApi.update(id, payload) : incidentsApi.create(payload);

    request
      .then((saved) => navigate(`/detail/${saved.id}`))
      .catch((e) => setServerError(e.message))
      .finally(() => setSubmitting(false));
  }

  if (loading) return <Spinner />;

  return (
    <div className="form-card">
      <h1>{isEdit ? "Редактирование инцидента" : "Новый инцидент"}</h1>
      <ErrorBanner message={serverError} />

      <form onSubmit={handleSubmit} noValidate>
        <label htmlFor="title">
          Заголовок
          <input
            id="title"
            type="text"
            value={values.title}
            onChange={(e) => handleChange("title", e.target.value)}
          />
          {errors.title && <span className="field-error">{errors.title}</span>}
        </label>

        <label htmlFor="service">
          Электронный сервис
          <input
            id="service"
            type="text"
            value={values.service}
            onChange={(e) => handleChange("service", e.target.value)}
          />
          {errors.service && <span className="field-error">{errors.service}</span>}
        </label>

        <label htmlFor="source">
          Источник сигнала
          <input
            id="source"
            type="text"
            value={values.source}
            onChange={(e) => handleChange("source", e.target.value)}
          />
          {errors.source && <span className="field-error">{errors.source}</span>}
        </label>

        <label htmlFor="threat_level">
          Степень угрозы (1–10)
          <input
            id="threat_level"
            type="number"
            min="1"
            max="10"
            value={values.threat_level}
            onChange={(e) => handleChange("threat_level", e.target.value)}
          />
          {errors.threat_level && <span className="field-error">{errors.threat_level}</span>}
        </label>

        <label htmlFor="status">
          Статус
          <select id="status" value={values.status} onChange={(e) => handleChange("status", e.target.value)}>
            {STATUSES.map((s) => (
              <option key={s} value={s}>
                {s}
              </option>
            ))}
          </select>
        </label>

        <label htmlFor="occurred_at">
          Дата и время
          <input
            id="occurred_at"
            type="datetime-local"
            value={values.occurred_at}
            onChange={(e) => handleChange("occurred_at", e.target.value)}
          />
          {errors.occurred_at && <span className="field-error">{errors.occurred_at}</span>}
        </label>

        <label htmlFor="responsible">
          Ответственный
          <input
            id="responsible"
            type="text"
            value={values.responsible}
            onChange={(e) => handleChange("responsible", e.target.value)}
          />
          {errors.responsible && <span className="field-error">{errors.responsible}</span>}
        </label>

        <label htmlFor="description">
          Описание
          <textarea
            id="description"
            rows={4}
            value={values.description}
            onChange={(e) => handleChange("description", e.target.value)}
          />
        </label>

        <div className="form-actions">
          <button type="submit" className="button" disabled={submitting}>
            {submitting ? "Сохранение…" : "Сохранить"}
          </button>
        </div>
      </form>
    </div>
  );
}
