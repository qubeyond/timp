from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from .. import models, schemas
from ..database import get_db

router = APIRouter(prefix="/incidents", tags=["incidents"])


@router.get("", response_model=list[schemas.IncidentOut])
def list_incidents(db: Session = Depends(get_db)):
    return db.query(models.Incident).order_by(models.Incident.occurred_at.desc()).all()


@router.get("/{incident_id}", response_model=schemas.IncidentOut)
def get_incident(incident_id: int, db: Session = Depends(get_db)):
    incident = db.get(models.Incident, incident_id)
    if incident is None:
        raise HTTPException(status_code=404, detail="Инцидент не найден")
    return incident


@router.post("", response_model=schemas.IncidentOut, status_code=201)
def create_incident(payload: schemas.IncidentCreate, db: Session = Depends(get_db)):
    incident = models.Incident(**payload.model_dump())
    db.add(incident)
    db.commit()
    db.refresh(incident)
    return incident


@router.put("/{incident_id}", response_model=schemas.IncidentOut)
def update_incident(incident_id: int, payload: schemas.IncidentUpdate, db: Session = Depends(get_db)):
    incident = db.get(models.Incident, incident_id)
    if incident is None:
        raise HTTPException(status_code=404, detail="Инцидент не найден")
    for field, value in payload.model_dump().items():
        setattr(incident, field, value)
    db.commit()
    db.refresh(incident)
    return incident


@router.delete("/{incident_id}", status_code=204)
def delete_incident(incident_id: int, db: Session = Depends(get_db)):
    incident = db.get(models.Incident, incident_id)
    if incident is None:
        raise HTTPException(status_code=404, detail="Инцидент не найден")
    db.delete(incident)
    db.commit()
    return None
