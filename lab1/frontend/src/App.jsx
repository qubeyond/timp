import { Link, Route, Routes } from "react-router-dom";
import Home from "./pages/Home.jsx";
import Detail from "./pages/Detail.jsx";
import IncidentForm from "./pages/IncidentForm.jsx";
import NotFound from "./pages/NotFound.jsx";

export default function App() {
  return (
    <div className="layout">
      <header className="topbar">
        <Link to="/" className="brand">
          Журнал инцидентов безопасности электронных сервисов
        </Link>
        <Link to="/add" className="add-link">
          + Новый инцидент
        </Link>
      </header>
      <main className="content">
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/detail/:id" element={<Detail />} />
          <Route path="/add" element={<IncidentForm mode="add" />} />
          <Route path="/edit/:id" element={<IncidentForm mode="edit" />} />
          <Route path="*" element={<NotFound />} />
        </Routes>
      </main>
    </div>
  );
}
