CREATE TABLE customer_status_type (
    customer_status_code  CHAR(3)     NOT NULL,
    name                  VARCHAR(50) NOT NULL,
    is_active             BOOLEAN     NOT NULL DEFAULT TRUE,

    CONSTRAINT pk_customer_status_type      PRIMARY KEY (customer_status_code),
    CONSTRAINT uk_customer_status_type_name UNIQUE (name),

    CONSTRAINT chk_customer_status_type_code_three_ascii_letters
        CHECK (customer_status_code ~ '^[A-Z]{3}$'),
    CONSTRAINT chk_customer_status_type_name_not_blank
        CHECK (name !~ '^[[:space:]]*$')
);

INSERT INTO customer_status_type (customer_status_code, name, is_active) VALUES
    ('ACT', 'ACTIVE',   TRUE),
    ('PND', 'PENDING',  TRUE),
    ('INA', 'INACTIVE', TRUE);


CREATE TABLE customer (
    person_id                    INTEGER NOT NULL,
    customer_status_code         CHAR(3) NOT NULL DEFAULT 'ACT',
    consents_to_data_processing  BOOLEAN NOT NULL DEFAULT FALSE,

    CONSTRAINT pk_customer PRIMARY KEY (person_id),

    CONSTRAINT fk_customer_person
        FOREIGN KEY (person_id)
        REFERENCES person (person_id)
        ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT fk_customer_customer_status_type
        FOREIGN KEY (customer_status_code)
        REFERENCES customer_status_type (customer_status_code)
        ON DELETE NO ACTION ON UPDATE CASCADE
);

CREATE INDEX ix_customer_status ON customer (customer_status_code);
