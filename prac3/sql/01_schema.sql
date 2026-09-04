DROP TABLE IF EXISTS incident_audit CASCADE;
DROP TABLE IF EXISTS incident_log CASCADE;
DROP TABLE IF EXISTS response_measures CASCADE;
DROP TABLE IF EXISTS incident_vulnerabilities CASCADE;
DROP TABLE IF EXISTS incidents CASCADE;
DROP TABLE IF EXISTS e_services CASCADE;
DROP TABLE IF EXISTS vulnerabilities CASCADE;
DROP TABLE IF EXISTS staff CASCADE;
DROP TABLE IF EXISTS incident_sources CASCADE;

CREATE TABLE incident_sources (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(150) NOT NULL,
    type        VARCHAR(150) NOT NULL,
    channel     VARCHAR(200),
    description TEXT
);

CREATE TABLE staff (
    id          SERIAL PRIMARY KEY,
    last_name   VARCHAR(100) NOT NULL,
    first_name  VARCHAR(100) NOT NULL,
    middle_name VARCHAR(100),
    position    VARCHAR(150) NOT NULL,
    department  VARCHAR(150) NOT NULL,
    phone       VARCHAR(20),
    email       VARCHAR(150)
);

CREATE TABLE vulnerabilities (
    id             SERIAL PRIMARY KEY,
    name           VARCHAR(150) NOT NULL,
    type           VARCHAR(100) NOT NULL,
    system_version VARCHAR(100),
    severity_level INT NOT NULL CHECK (severity_level BETWEEN 1 AND 10),
    fix_status     VARCHAR(150) NOT NULL,
    description    TEXT,
    last_modified  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE e_services (
    id                SERIAL PRIMARY KEY,
    name              VARCHAR(150) NOT NULL,
    type              VARCHAR(100) NOT NULL,
    provider          VARCHAR(100) NOT NULL,
    endpoint_url      VARCHAR(200),
    security_category INT NOT NULL CHECK (security_category >= 1),
    description       TEXT
);

CREATE TABLE incidents (
    id              SERIAL PRIMARY KEY,
    staff_id        INT NOT NULL REFERENCES staff(id),
    service_id      INT NOT NULL REFERENCES e_services(id),
    vulnerability_id INT REFERENCES vulnerabilities(id),
    source_id       INT NOT NULL REFERENCES incident_sources(id),
    occurred_at     TIMESTAMP NOT NULL,
    type            VARCHAR(100),
    threat_level    INT NOT NULL CHECK (threat_level BETWEEN 1 AND 10),
    status          VARCHAR(100) NOT NULL,
    description     TEXT,
    last_modified   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE incident_vulnerabilities (
    incident_id     INT NOT NULL REFERENCES incidents(id) ON DELETE CASCADE,
    vulnerability_id INT NOT NULL REFERENCES vulnerabilities(id) ON DELETE CASCADE,
    PRIMARY KEY (incident_id, vulnerability_id)
);

CREATE TABLE response_measures (
    id           SERIAL PRIMARY KEY,
    staff_id     INT NOT NULL REFERENCES staff(id),
    incident_id  INT NOT NULL REFERENCES incidents(id),
    name         VARCHAR(150) NOT NULL,
    description  TEXT,
    performed_at TIMESTAMP NOT NULL,
    result       VARCHAR(150)
);

CREATE TABLE incident_log (
    id          SERIAL PRIMARY KEY,
    incident_id INT NOT NULL,
    action_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    app_user    VARCHAR(100) NOT NULL,
    action      VARCHAR(20) NOT NULL
);

CREATE TABLE incident_audit (
    id                SERIAL PRIMARY KEY,
    incident_id       INT NOT NULL,
    action_at         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    app_user          VARCHAR(100) NOT NULL,
    old_status        VARCHAR(100),
    new_status        VARCHAR(100),
    old_threat_level  INT,
    new_threat_level  INT,
    old_description   TEXT,
    new_description   TEXT
);
