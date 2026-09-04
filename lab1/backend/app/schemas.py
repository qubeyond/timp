from datetime import datetime
from typing import Literal, Optional

from pydantic import BaseModel, ConfigDict, Field

Status = Literal["Новый", "В работе", "Завершён", "Закрыт"]


class IncidentBase(BaseModel):
    title: str = Field(min_length=3, max_length=200)
    service: str = Field(min_length=2, max_length=150)
    source: str = Field(min_length=2, max_length=150)
    threat_level: int = Field(ge=1, le=10)
    status: Status
    occurred_at: datetime
    responsible: str = Field(min_length=2, max_length=150)
    description: Optional[str] = None


class IncidentCreate(IncidentBase):
    pass


class IncidentUpdate(IncidentBase):
    pass


class IncidentOut(IncidentBase):
    model_config = ConfigDict(from_attributes=True)

    id: int
    created_at: datetime
