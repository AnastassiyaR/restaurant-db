CREATE TABLE employee_status_type (
    employee_status_code  CHAR(3)     NOT NULL,
    name                  VARCHAR(50) NOT NULL,
    is_active             BOOLEAN     NOT NULL DEFAULT TRUE,

    CONSTRAINT pk_employee_status_type      PRIMARY KEY (employee_status_code),
    CONSTRAINT uk_employee_status_type_name UNIQUE (name),

    CONSTRAINT chk_employee_status_type_code_three_ascii_letters
        CHECK (employee_status_code ~ '^[A-Z]{3}$'),
    CONSTRAINT chk_employee_status_type_name_not_blank
        CHECK (name !~ '^[[:space:]]*$')
);

INSERT INTO employee_status_type (employee_status_code, name, is_active) VALUES
    ('ACT', 'ACTIVE',   TRUE),
    ('PND', 'PENDING',  TRUE),
    ('INA', 'INACTIVE', TRUE);


CREATE TABLE employee (
    person_id             INTEGER NOT NULL,
    employee_status_code  CHAR(3) NOT NULL DEFAULT 'PND',
    mentor_id             INTEGER NULL,

    CONSTRAINT pk_employee PRIMARY KEY (person_id),

    CONSTRAINT fk_employee_person
        FOREIGN KEY (person_id)
        REFERENCES person (person_id)
        ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT fk_employee_employee_status_type
        FOREIGN KEY (employee_status_code)
        REFERENCES employee_status_type (employee_status_code)
        ON DELETE NO ACTION ON UPDATE CASCADE,
    CONSTRAINT fk_employee_mentor
        FOREIGN KEY (mentor_id)
        REFERENCES employee (person_id)
        ON DELETE SET NULL ON UPDATE NO ACTION,

    CONSTRAINT chk_employee_not_own_mentor
        CHECK (person_id <> mentor_id)
);

CREATE INDEX ix_employee_status ON employee (employee_status_code);
CREATE INDEX ix_employee_mentor ON employee (mentor_id);


CREATE TABLE employee_role (
    employee_role_code  CHAR(3)     NOT NULL,
    name                VARCHAR(50) NOT NULL,
    description         TEXT        NULL,
    is_active           BOOLEAN     NOT NULL DEFAULT TRUE,

    CONSTRAINT pk_employee_role      PRIMARY KEY (employee_role_code),
    CONSTRAINT uk_employee_role_name UNIQUE (name),

    CONSTRAINT chk_employee_role_code_three_ascii_letters
        CHECK (employee_role_code ~ '^[A-Z]{3}$'),
    CONSTRAINT chk_employee_role_name_not_blank
        CHECK (name !~ '^[[:space:]]*$'),
    CONSTRAINT chk_employee_role_description_not_blank
        CHECK (description !~ '^[[:space:]]*$')
);

INSERT INTO employee_role (employee_role_code, name, description, is_active) VALUES
    ('HDC', 'Head chef',
        'Responsible for building the menu, organising kitchen work and food quality.', TRUE),
    ('CHF', 'Cook',
        'Prepares dishes according to recipes and the head chef''s instructions.', TRUE),
    ('WTR', 'Waiter',
        'Serves guests: takes orders, serves food and drinks, and handles payment.', TRUE),
    ('BAR', 'Bartender',
        'Prepares and serves drinks and manages bar inventory.', TRUE),
    ('SHS', 'Shift supervisor',
        'Coordinates staff during a shift and resolves day-to-day issues.', TRUE),
    ('CLN', 'Cleaner',
        'Keeps the dining room and kitchen clean and compliant with hygiene rules.', TRUE);


CREATE TABLE employee_role_assignment (
    employee_role_assignment_id  INTEGER        GENERATED ALWAYS AS IDENTITY NOT NULL,
    employee_role_code           CHAR(3)        NOT NULL,
    start_time                   TIMESTAMPTZ(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0),
    end_time                     TIMESTAMPTZ(0) NOT NULL DEFAULT 'infinity',
    person_id                    INTEGER        NOT NULL,

    CONSTRAINT pk_employee_role_assignment PRIMARY KEY (employee_role_assignment_id),
    CONSTRAINT uk_employee_role_assignment UNIQUE (start_time, employee_role_code, person_id),

    CONSTRAINT fk_employee_role_assignment_employee
        FOREIGN KEY (person_id)
        REFERENCES employee (person_id)
        ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT fk_employee_role_assignment_employee_role
        FOREIGN KEY (employee_role_code)
        REFERENCES employee_role (employee_role_code)
        ON DELETE NO ACTION ON UPDATE CASCADE,

    CONSTRAINT chk_employee_role_assignment_start_time_in_range
        CHECK (start_time >= '2010-01-01 00:00:00' AT TIME ZONE 'Europe/Tallinn'
           AND start_time <  '2101-01-01 00:00:00' AT TIME ZONE 'Europe/Tallinn'),
    CONSTRAINT chk_employee_role_assignment_end_time_in_range
        CHECK (end_time = 'infinity'
            OR (end_time >= '2010-01-01 00:00:00' AT TIME ZONE 'Europe/Tallinn'
            AND end_time <  '2101-01-01 00:00:00' AT TIME ZONE 'Europe/Tallinn')),
    CONSTRAINT chk_employee_role_assignment_end_after_start
        CHECK (end_time > start_time)
);

CREATE INDEX ix_employee_role_assignment_role     ON employee_role_assignment (employee_role_code);
CREATE INDEX ix_employee_role_assignment_employee ON employee_role_assignment (person_id);
