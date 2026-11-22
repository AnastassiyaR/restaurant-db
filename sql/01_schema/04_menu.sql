CREATE TABLE menu_item_type (
    menu_item_type_code  CHAR(3)     NOT NULL,
    name                 VARCHAR(50) NOT NULL,
    is_active            BOOLEAN     NOT NULL DEFAULT TRUE,

    CONSTRAINT pk_menu_item_type      PRIMARY KEY (menu_item_type_code),
    CONSTRAINT uk_menu_item_type_name UNIQUE (name),

    CONSTRAINT chk_menu_item_type_code_three_ascii_letters
        CHECK (menu_item_type_code ~ '^[A-Z]{3}$'),
    CONSTRAINT chk_menu_item_type_name_not_blank
        CHECK (name !~ '^[[:space:]]*$')
);

INSERT INTO menu_item_type (menu_item_type_code, name, is_active) VALUES
    ('FOD', 'Food',  TRUE),
    ('DRK', 'Drink', TRUE),
    ('OTH', 'Other', TRUE);


CREATE TABLE menu_item_status_type (
    menu_item_status_code  CHAR(3)     NOT NULL,
    name                   VARCHAR(50) NOT NULL,
    is_active              BOOLEAN     NOT NULL DEFAULT TRUE,

    CONSTRAINT pk_menu_item_status_type      PRIMARY KEY (menu_item_status_code),
    CONSTRAINT uk_menu_item_status_type_name UNIQUE (name),

    CONSTRAINT chk_menu_item_status_type_code_three_ascii_letters
        CHECK (menu_item_status_code ~ '^[A-Z]{3}$'),
    CONSTRAINT chk_menu_item_status_type_name_not_blank
        CHECK (name !~ '^[[:space:]]*$')
);

INSERT INTO menu_item_status_type (menu_item_status_code, name, is_active) VALUES
    ('ACT', 'ACTIVE',       TRUE),
    ('PND', 'PENDING',      TRUE),
    ('INA', 'INACTIVE',     TRUE),
    ('DSC', 'DISCONTINUED', TRUE);


CREATE TABLE menu_item (
    menu_item_id           INTEGER        NOT NULL,
    name                   VARCHAR(100)   NOT NULL,
    description            TEXT,
    price                  DECIMAL(10, 2) NOT NULL,
    calories               INTEGER        NOT NULL,
    menu_item_status_code  CHAR(3)        NOT NULL DEFAULT 'PND',
    menu_item_type_code    CHAR(3)        NOT NULL DEFAULT 'FOD',
    registered_at          TIMESTAMPTZ(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0),
    last_modified_at       TIMESTAMPTZ(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0),
    registered_by_id       INTEGER        NOT NULL,
    last_modified_by_id    INTEGER        NOT NULL,

    CONSTRAINT pk_menu_item      PRIMARY KEY (menu_item_id),
    CONSTRAINT uk_menu_item_name UNIQUE (name),

    CONSTRAINT fk_menu_item_last_modified_by
        FOREIGN KEY (last_modified_by_id)
        REFERENCES employee (person_id)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT fk_menu_item_registered_by
        FOREIGN KEY (registered_by_id)
        REFERENCES employee (person_id)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT fk_menu_item_menu_item_status_type
        FOREIGN KEY (menu_item_status_code)
        REFERENCES menu_item_status_type (menu_item_status_code)
        ON DELETE NO ACTION ON UPDATE CASCADE,
    CONSTRAINT fk_menu_item_menu_item_type
        FOREIGN KEY (menu_item_type_code)
        REFERENCES menu_item_type (menu_item_type_code)
        ON DELETE NO ACTION ON UPDATE CASCADE,

    CONSTRAINT chk_menu_item_name_not_blank
        CHECK (name !~ '^[[:space:]]*$'),
    CONSTRAINT chk_menu_item_description_not_blank
        CHECK (description !~ '^[[:space:]]*$'),
    CONSTRAINT chk_menu_item_price_positive
        CHECK (price > 0),
    CONSTRAINT chk_menu_item_calories_non_negative
        CHECK (calories >= 0),
    CONSTRAINT chk_menu_item_registered_at_in_range
        CHECK (registered_at >= '2010-01-01 00:00:00' AT TIME ZONE 'Europe/Tallinn'
           AND registered_at <  '2101-01-01 00:00:00' AT TIME ZONE 'Europe/Tallinn'),
    CONSTRAINT chk_menu_item_last_modified_at_in_range
        CHECK (last_modified_at >= '2010-01-01 00:00:00' AT TIME ZONE 'Europe/Tallinn'
           AND last_modified_at <  '2101-01-01 00:00:00' AT TIME ZONE 'Europe/Tallinn'),
    CONSTRAINT chk_menu_item_last_modified_at_gte_registered_at
        CHECK (last_modified_at >= registered_at)
);

CREATE INDEX ix_menu_item_last_modified_by ON menu_item (last_modified_by_id);
CREATE INDEX ix_menu_item_registered_by    ON menu_item (registered_by_id);
CREATE INDEX ix_menu_item_status           ON menu_item (menu_item_status_code);
CREATE INDEX ix_menu_item_type             ON menu_item (menu_item_type_code);


CREATE TABLE menu_item_category_type (
    menu_item_category_type_code  CHAR(3)     NOT NULL,
    name                          VARCHAR(50) NOT NULL,
    is_active                     BOOLEAN     NOT NULL DEFAULT TRUE,

    CONSTRAINT pk_menu_item_category_type      PRIMARY KEY (menu_item_category_type_code),
    CONSTRAINT uk_menu_item_category_type_name UNIQUE (name),

    CONSTRAINT chk_menu_item_category_type_code_three_ascii_letters
        CHECK (menu_item_category_type_code ~ '^[A-Z]{3}$'),
    CONSTRAINT chk_menu_item_category_type_name_not_blank
        CHECK (name !~ '^[[:space:]]*$')
);

INSERT INTO menu_item_category_type (menu_item_category_type_code, name, is_active) VALUES
    ('ALG', 'Allergen',   TRUE),
    ('ING', 'Ingredient', TRUE);


CREATE TABLE menu_item_category (
    menu_item_category_code       CHAR(3)     NOT NULL,
    name                          VARCHAR(50) NOT NULL,
    menu_item_category_type_code  CHAR(3)     NOT NULL,
    is_active                     BOOLEAN     NOT NULL DEFAULT TRUE,

    CONSTRAINT pk_menu_item_category PRIMARY KEY (menu_item_category_code),
    CONSTRAINT uk_menu_item_category_name_type
        UNIQUE (name, menu_item_category_type_code),

    CONSTRAINT fk_menu_item_category_menu_item_category_type
        FOREIGN KEY (menu_item_category_type_code)
        REFERENCES menu_item_category_type (menu_item_category_type_code)
        ON DELETE NO ACTION ON UPDATE CASCADE,

    CONSTRAINT chk_menu_item_category_code_three_ascii_letters
        CHECK (menu_item_category_code ~ '^[A-Z]{3}$'),
    CONSTRAINT chk_menu_item_category_name_not_blank
        CHECK (name !~ '^[[:space:]]*$')
);

CREATE INDEX ix_menu_item_category_type ON menu_item_category (menu_item_category_type_code);

INSERT INTO menu_item_category (menu_item_category_code, name, menu_item_category_type_code, is_active) VALUES
    ('GLT', 'Gluten',               'ALG', TRUE),
    ('NUT', 'Nuts',                 'ALG', TRUE),
    ('LAC', 'Lactose',              'ALG', TRUE),
    ('EGG', 'Egg',                  'ALG', TRUE),
    ('MEA', 'Meat',                 'ING', TRUE),
    ('FSH', 'Fish and seafood',     'ING', TRUE),
    ('VEG', 'Vegetables',           'ING', TRUE),
    ('FRU', 'Fruits and berries',   'ING', TRUE);


CREATE TABLE menu_item_category_assignment (
    menu_item_id             INTEGER NOT NULL,
    menu_item_category_code  CHAR(3) NOT NULL,

    CONSTRAINT pk_menu_item_category_assignment
        PRIMARY KEY (menu_item_id, menu_item_category_code),

    CONSTRAINT fk_menu_item_category_assignment_menu_item
        FOREIGN KEY (menu_item_id)
        REFERENCES menu_item (menu_item_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_menu_item_category_assignment_menu_item_category
        FOREIGN KEY (menu_item_category_code)
        REFERENCES menu_item_category (menu_item_category_code)
        ON DELETE NO ACTION ON UPDATE CASCADE
);

CREATE INDEX ix_menu_item_category_assignment_category
    ON menu_item_category_assignment (menu_item_category_code);
