from datetime import datetime, timedelta

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from . import models
from .database import Base, SessionLocal, engine
from .routers import incidents

app = FastAPI(title="Журнал инцидентов безопасности электронных сервисов")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(incidents.router)


@app.get("/health")
def health():
    return {"status": "ok"}


def seed_if_empty():
    db = SessionLocal()
    try:
        if db.query(models.Incident).count() > 0:
            return
        now = datetime.utcnow()
        demo = [
            models.Incident(
                title="Подмена ID в запросах к личному кабинету",
                service="Интернет-банк",
                source="WAF периметра",
                threat_level=8,
                status="В работе",
                occurred_at=now - timedelta(days=3),
                responsible="Соколов В.О.",
                description="Попытка доступа к чужим счетам через подмену идентификатора объекта.",
            ),
            models.Incident(
                title="Утечка API-ключа платёжного шлюза",
                service="Платёжный шлюз",
                source="Мониторинг соцсетей",
                threat_level=9,
                status="Завершён",
                occurred_at=now - timedelta(days=8),
                responsible="Соколов В.О.",
                description="Ключ доступа обнаружен в публичном репозитории, отозван и перевыпущен.",
            ),
            models.Incident(
                title="Подозрительная серия платежей",
                service="Маркетплейс",
                source="Антифрод-система",
                threat_level=5,
                status="Новый",
                occurred_at=now - timedelta(hours=6),
                responsible="Егорова А.С.",
                description="Серия мелких платежей с разных карт на один аккаунт продавца.",
            ),
        ]
        db.add_all(demo)
        db.commit()
    finally:
        db.close()


@app.on_event("startup")
def on_startup():
    Base.metadata.create_all(bind=engine)
    seed_if_empty()
