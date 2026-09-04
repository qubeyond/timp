export default function Spinner() {
  return (
    <div className="spinner" role="status" aria-label="Загрузка">
      <div className="spinner-circle" />
      <span>Загрузка…</span>
    </div>
  );
}
