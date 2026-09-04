from sqlalchemy import Column, DateTime, Integer, String, Text
from sqlalchemy.sql import func

from .database import Base


class Incident(Base):
    __tablename__ = "incidents"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(200), nullable=False)
    service = Column(String(150), nullable=False)
    source = Column(String(150), nullable=False)
    threat_level = Column(Integer, nullable=False)
    status = Column(String(50), nullable=False, default="Новый")
    occurred_at = Column(DateTime, nullable=False)
    responsible = Column(String(150), nullable=False)
    description = Column(Text, nullable=True)
    created_at = Column(DateTime, server_default=func.now(), nullable=False)
