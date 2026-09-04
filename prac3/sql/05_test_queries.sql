SELECT fn_avg_response_time(1) AS avg_response_hours;

SELECT fn_check_threat_level(1) AS is_threat_level_valid;

SELECT fn_incident_count_period('2026-05-01', '2026-05-31 23:59:59') AS incidents_in_period;

SELECT * FROM fn_top_vulnerabilities_by_quarter(2026, 2);

SELECT fn_measures_count(1) AS measures_count;

INSERT INTO incidents (staff_id, service_id, vulnerability_id, source_id, occurred_at, type, threat_level, status, description)
VALUES (2, 3, NULL, 3, '2026-06-05 10:00', 'Мошенничество', 5, 'Новый', 'Подозрительная серия платежей');

SELECT * FROM incident_log ORDER BY id DESC LIMIT 1;

UPDATE incidents SET status = 'В работе', threat_level = 6 WHERE id = 6;

SELECT * FROM incident_audit ORDER BY id DESC LIMIT 1;
SELECT id, status, threat_level, last_modified FROM incidents WHERE id = 6;

INSERT INTO incidents (staff_id, service_id, source_id, occurred_at, type, threat_level, status, description)
VALUES (2, 3, 4, '2026-05-25 09:00', 'Ложное срабатывание', 2, 'Закрыт', 'Проверка подтвердила отсутствие реального инцидента');

DELETE FROM incidents
WHERE status = 'Закрыт' AND description = 'Проверка подтвердила отсутствие реального инцидента';

UPDATE vulnerabilities SET fix_status = 'Исправлена' WHERE id = 2;
INSERT INTO incident_vulnerabilities (incident_id, vulnerability_id) VALUES (6, 2);
SELECT id, name, fix_status, last_modified FROM vulnerabilities WHERE id = 2;
