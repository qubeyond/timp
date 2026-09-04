CREATE OR REPLACE FUNCTION fn_log_incident_insert()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO incident_log (incident_id, action_at, app_user, action)
    VALUES (NEW.id, CURRENT_TIMESTAMP, CURRENT_USER, 'INSERT');
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_log_incident_insert
AFTER INSERT ON incidents
FOR EACH ROW
EXECUTE FUNCTION fn_log_incident_insert();

CREATE OR REPLACE FUNCTION fn_audit_incident_update()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO incident_audit (
        incident_id, action_at, app_user,
        old_status, new_status,
        old_threat_level, new_threat_level,
        old_description, new_description
    )
    VALUES (
        OLD.id, CURRENT_TIMESTAMP, CURRENT_USER,
        OLD.status, NEW.status,
        OLD.threat_level, NEW.threat_level,
        OLD.description, NEW.description
    );
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_audit_incident_update
AFTER UPDATE ON incidents
FOR EACH ROW
EXECUTE FUNCTION fn_audit_incident_update();

CREATE OR REPLACE FUNCTION fn_validate_threat_level()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.threat_level IS NULL THEN
        RAISE EXCEPTION 'Степень угрозы не может быть NULL';
    END IF;

    IF NEW.threat_level < 1 OR NEW.threat_level > 10 THEN
        RAISE EXCEPTION 'Некорректная степень угрозы: %. Допустимый диапазон: 1..10', NEW.threat_level;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_validate_threat_level
BEFORE INSERT OR UPDATE ON incidents
FOR EACH ROW
EXECUTE FUNCTION fn_validate_threat_level();

CREATE OR REPLACE FUNCTION fn_prevent_incident_delete()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF OLD.status NOT IN ('Завершён', 'Закрыт') THEN
        RAISE EXCEPTION 'Удаление запрещено: инцидент % имеет статус "%". Разрешено удалять только завершённые или закрытые инциденты.',
            OLD.id, OLD.status;
    END IF;

    RETURN OLD;
END;
$$;

CREATE TRIGGER trg_prevent_incident_delete
BEFORE DELETE ON incidents
FOR EACH ROW
EXECUTE FUNCTION fn_prevent_incident_delete();

CREATE OR REPLACE FUNCTION fn_vulnerability_relink_control()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_status VARCHAR(150);
BEGIN
    SELECT fix_status INTO v_status
    FROM vulnerabilities
    WHERE id = NEW.vulnerability_id;

    IF v_status = 'Исправлена' THEN
        UPDATE vulnerabilities
        SET fix_status = 'Повторно открыта',
            last_modified = CURRENT_TIMESTAMP
        WHERE id = NEW.vulnerability_id;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_vulnerability_relink
BEFORE INSERT OR UPDATE ON incident_vulnerabilities
FOR EACH ROW
EXECUTE FUNCTION fn_vulnerability_relink_control();

CREATE OR REPLACE FUNCTION fn_update_last_modified()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.last_modified := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_incident_last_modified
BEFORE UPDATE ON incidents
FOR EACH ROW
EXECUTE FUNCTION fn_update_last_modified();

CREATE TRIGGER trg_vulnerability_last_modified
BEFORE UPDATE ON vulnerabilities
FOR EACH ROW
EXECUTE FUNCTION fn_update_last_modified();
