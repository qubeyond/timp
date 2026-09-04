INSERT INTO incidents (staff_id, service_id, source_id, occurred_at, threat_level, status)
VALUES (1, 1, 1, NOW(), 15, 'Новый');

DELETE FROM incidents WHERE id = 6;
