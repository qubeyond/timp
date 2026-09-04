CREATE OR REPLACE FUNCTION fn_avg_response_time(p_staff_id INT)
RETURNS NUMERIC(10,2)
LANGUAGE plpgsql
AS $$
DECLARE
    v_avg_hours NUMERIC(10,2);
BEGIN
    SELECT ROUND(AVG(EXTRACT(EPOCH FROM (rm.first_response - i.occurred_at)) / 3600.0)::NUMERIC, 2)
    INTO v_avg_hours
    FROM incidents i
    JOIN (
        SELECT incident_id, MIN(performed_at) AS first_response
        FROM response_measures
        GROUP BY incident_id
    ) rm ON i.id = rm.incident_id
    WHERE i.staff_id = p_staff_id;

    RETURN v_avg_hours;
END;
$$;

CREATE OR REPLACE FUNCTION fn_check_threat_level(p_incident_id INT)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    v_threat_level INT;
BEGIN
    SELECT threat_level INTO v_threat_level
    FROM incidents
    WHERE id = p_incident_id;

    IF v_threat_level IS NULL THEN
        RETURN FALSE;
    ELSIF v_threat_level BETWEEN 1 AND 10 THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END;
$$;

CREATE OR REPLACE FUNCTION fn_incident_count_period(p_start TIMESTAMP, p_end TIMESTAMP)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_count INT;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM incidents
    WHERE occurred_at BETWEEN p_start AND p_end;

    RETURN v_count;
END;
$$;

CREATE OR REPLACE FUNCTION fn_top_vulnerabilities_by_quarter(p_year INT, p_quarter INT)
RETURNS TABLE (
    vulnerability_id   INT,
    vulnerability_name VARCHAR,
    mentions           BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT v.id, v.name, COUNT(iv.incident_id) AS mentions
    FROM vulnerabilities v
    JOIN incident_vulnerabilities iv ON v.id = iv.vulnerability_id
    JOIN incidents i ON i.id = iv.incident_id
    WHERE EXTRACT(YEAR FROM i.occurred_at) = p_year
      AND EXTRACT(QUARTER FROM i.occurred_at) = p_quarter
    GROUP BY v.id, v.name
    ORDER BY COUNT(iv.incident_id) DESC;
END;
$$;

CREATE OR REPLACE FUNCTION fn_measures_count(p_incident_id INT)
RETURNS INT
LANGUAGE sql
AS $$
    SELECT COUNT(*)
    FROM response_measures
    WHERE incident_id = p_incident_id;
$$;
