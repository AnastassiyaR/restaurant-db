CREATE TABLE country (
    country_code  CHAR(3)     NOT NULL,
    name          VARCHAR(50) NOT NULL,
    is_active     BOOLEAN     NOT NULL DEFAULT TRUE,

    CONSTRAINT pk_country      PRIMARY KEY (country_code),
    CONSTRAINT uk_country_name UNIQUE (name),

    CONSTRAINT chk_country_name_not_blank
        CHECK (name !~ '^[[:space:]]*$'),
    CONSTRAINT chk_country_code_three_ascii_letters
        CHECK (country_code ~ '^[A-Z]{3}$')
);

INSERT INTO country (country_code, name, is_active) VALUES
    ('EST', 'Estonia', TRUE),
    ('POL', 'Poland',  TRUE),
    ('ENG', 'England', TRUE),
    ('SWE', 'Sweden',  FALSE);


CREATE TABLE person_status_type (
    person_status_code  CHAR(3)     NOT NULL,
    name                VARCHAR(50) NOT NULL,
    is_active           BOOLEAN     NOT NULL DEFAULT TRUE,

    CONSTRAINT pk_person_status_type      PRIMARY KEY (person_status_code),
    CONSTRAINT uk_person_status_type_name UNIQUE (name),

    CONSTRAINT chk_person_status_type_name_not_blank
        CHECK (name !~ '^[[:space:]]*$'),
    CONSTRAINT chk_person_status_type_code_three_ascii_letters
        CHECK (person_status_code ~ '^[A-Z]{3}$')
);

INSERT INTO person_status_type (person_status_code, name, is_active) VALUES
    ('ACT', 'ACTIVE',   TRUE),
    ('PND', 'PENDING',  TRUE),
    ('INA', 'INACTIVE', TRUE);


CREATE TABLE person (
    person_id           INTEGER        GENERATED ALWAYS AS IDENTITY NOT NULL,
    national_id         VARCHAR(20)    NOT NULL,
    country_code        CHAR(3)        NOT NULL,
    email               VARCHAR(254)   NOT NULL,
    person_status_code  CHAR(3)        NOT NULL DEFAULT 'PND',
    birth_date          DATE           NOT NULL,
    registered_at       TIMESTAMPTZ(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0),
    last_modified_at    TIMESTAMPTZ(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0),
    first_name          VARCHAR(50),
    last_name           VARCHAR(50),
    residence           VARCHAR(255),

    CONSTRAINT pk_person PRIMARY KEY (person_id),
    CONSTRAINT uk_person_national_id_country UNIQUE (national_id, country_code),

    CONSTRAINT fk_person_person_status_type
        FOREIGN KEY (person_status_code)
        REFERENCES person_status_type (person_status_code)
        ON DELETE NO ACTION ON UPDATE CASCADE,
    CONSTRAINT fk_person_country
        FOREIGN KEY (country_code)
        REFERENCES country (country_code)
        ON DELETE NO ACTION ON UPDATE CASCADE,

    CONSTRAINT chk_person_birth_date_in_range
        CHECK (birth_date >= '1900-01-01' AND birth_date < '2101-01-01'),
    CONSTRAINT chk_person_birth_date_lte_registered_at
        CHECK (birth_date <= registered_at),
    CONSTRAINT chk_person_registered_at_in_range
        CHECK (registered_at >= '2010-01-01 00:00:00' AT TIME ZONE 'Europe/Tallinn'
           AND registered_at <  '2101-01-01 00:00:00' AT TIME ZONE 'Europe/Tallinn'),
    CONSTRAINT chk_person_last_modified_at_gte_registered_at
        CHECK (last_modified_at >= registered_at),
    CONSTRAINT chk_person_last_modified_at_in_range
        CHECK (last_modified_at >= '2010-01-01 00:00:00' AT TIME ZONE 'Europe/Tallinn'
           AND last_modified_at <  '2101-01-01 00:00:00' AT TIME ZONE 'Europe/Tallinn'),
    CONSTRAINT chk_person_first_or_last_name_present
        CHECK (first_name IS NOT NULL OR last_name IS NOT NULL),
    CONSTRAINT chk_person_national_id_not_blank
        CHECK (national_id !~ '^[[:space:]]*$'),
    CONSTRAINT chk_person_first_name_not_blank
        CHECK (first_name !~ '^[[:space:]]*$'),
    CONSTRAINT chk_person_last_name_not_blank
        CHECK (last_name !~ '^[[:space:]]*$'),
    CONSTRAINT chk_person_residence_not_blank
        CHECK (residence !~ '^[[:space:]]*$'),
    CONSTRAINT chk_person_residence_not_digits_only
        CHECK (residence !~ '^[0-9]+$'),
    CONSTRAINT chk_person_email_has_at_sign
        CHECK (email LIKE '%@%'),
    CONSTRAINT chk_person_estonian_national_id_is_11_digits
        CHECK (country_code <> 'EST' OR national_id ~ '^[0-9]{11}$'),
    CONSTRAINT chk_person_national_id_allowed_chars
        CHECK (national_id ~* '^[[:alpha:]0-9 \-+=\\\/]*$')
);

CREATE UNIQUE INDEX ux_person_email_ci       ON person (lower(email));
CREATE INDEX        ix_person_status         ON person (person_status_code);
CREATE INDEX        ix_person_country        ON person (country_code);


CREATE TABLE user_account (
    person_id         INTEGER        NOT NULL,
    registered_at     TIMESTAMPTZ(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0),
    last_modified_at  TIMESTAMPTZ(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0),
    password          VARCHAR(255)   NOT NULL,
    is_active         BOOLEAN        NOT NULL DEFAULT TRUE,

    CONSTRAINT pk_user_account PRIMARY KEY (person_id),
    CONSTRAINT fk_user_account_person
        FOREIGN KEY (person_id)
        REFERENCES person (person_id)
        ON DELETE CASCADE ON UPDATE NO ACTION,

    CONSTRAINT chk_user_account_password_not_blank
        CHECK (password !~ '^[[:space:]]*$'),
    CONSTRAINT chk_user_account_registered_at_in_range
        CHECK (registered_at >= '2010-01-01 00:00:00' AT TIME ZONE 'Europe/Tallinn'
           AND registered_at <  '2101-01-01 00:00:00' AT TIME ZONE 'Europe/Tallinn'),
    CONSTRAINT chk_user_account_last_modified_at_gte_registered_at
        CHECK (last_modified_at >= registered_at),
    CONSTRAINT chk_user_account_last_modified_at_in_range
        CHECK (last_modified_at >= '2010-01-01 00:00:00' AT TIME ZONE 'Europe/Tallinn'
           AND last_modified_at <  '2101-01-01 00:00:00' AT TIME ZONE 'Europe/Tallinn')
);
