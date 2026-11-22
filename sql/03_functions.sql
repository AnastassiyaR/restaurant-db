DROP FUNCTION IF EXISTS fn_is_manager(text, text);
DROP FUNCTION IF EXISTS fn_register_menu_item(integer, varchar, text, numeric, integer, varchar, char);
DROP FUNCTION IF EXISTS fn_delete_menu_item(integer);
DROP FUNCTION IF EXISTS fn_activate_menu_item(integer, varchar);
DROP FUNCTION IF EXISTS fn_deactivate_menu_item(integer, varchar);
DROP FUNCTION IF EXISTS fn_discontinue_menu_item(integer, varchar);
DROP FUNCTION IF EXISTS fn_update_menu_item(integer, integer, varchar, text, numeric, integer, char, varchar);
DROP FUNCTION IF EXISTS fn_add_menu_item_to_category(integer, char, varchar);
DROP FUNCTION IF EXISTS fn_remove_menu_item_from_category(integer, char, varchar);


-- Authentication helper: TRUE if an active employee with an active account
-- matches the given e-mail (case-insensitive) and password.
CREATE OR REPLACE FUNCTION fn_is_manager(
    p_username TEXT,
    p_password TEXT
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    result BOOLEAN;
BEGIN
    SELECT INTO result (ua.password = p_password)
    FROM person p
        JOIN employee     e  ON p.person_id = e.person_id
        JOIN user_account ua ON p.person_id = ua.person_id
    WHERE upper(p.email) = upper(p_username)
      AND e.employee_status_code = 'ACT'
      AND p.person_status_code   = 'ACT'
      AND ua.is_active           = TRUE;

    RETURN COALESCE(result, FALSE);
END;
$$;


-- OP1: register a new menu item (starts in status PND)
CREATE OR REPLACE FUNCTION fn_register_menu_item(
    p_menu_item_id       menu_item.menu_item_id%TYPE,
    p_name               menu_item.name%TYPE,
    p_description        menu_item.description%TYPE,
    p_price              menu_item.price%TYPE,
    p_calories           menu_item.calories%TYPE,
    p_email              person.email%TYPE,
    p_menu_item_type_code menu_item.menu_item_type_code%TYPE
)
RETURNS VOID
LANGUAGE sql
SECURITY DEFINER
SET search_path = public, pg_temp
BEGIN ATOMIC
    INSERT INTO menu_item (
        menu_item_id,
        name,
        description,
        price,
        calories,
        menu_item_status_code,
        menu_item_type_code,
        registered_at,
        last_modified_at,
        registered_by_id,
        last_modified_by_id
    )
    SELECT
        p_menu_item_id,
        p_name,
        p_description,
        p_price,
        p_calories,
        'PND',
        p_menu_item_type_code,
        CURRENT_TIMESTAMP(0),
        CURRENT_TIMESTAMP(0),
        e.person_id,
        e.person_id
    FROM employee AS e
        JOIN person AS p
            ON p.person_id = e.person_id
           AND lower(p.email) = lower(p_email)
        JOIN menu_item_type AS mit
            ON mit.menu_item_type_code = p_menu_item_type_code
           AND mit.is_active = TRUE
        JOIN menu_item_status_type AS mist
            ON mist.menu_item_status_code = 'PND'
           AND mist.is_active = TRUE;
END;

COMMENT ON FUNCTION fn_register_menu_item(integer, varchar, text, decimal, integer, varchar, char) IS
'Registers a new menu item (database operation OP1).
 Parameters: p_menu_item_id = item id; p_name = item name; p_description = description;
 p_price = price; p_calories = calorie count; p_email = case-insensitive e-mail of the
 registering employee; p_menu_item_type_code = menu item type code.
 Preconditions: if no employee has the given e-mail, or the item type is not active,
 the SELECT finds zero rows and no item is inserted.';


-- OP2: delete a menu item (only while PND)
CREATE OR REPLACE FUNCTION fn_delete_menu_item(
    p_menu_item_id menu_item.menu_item_id%TYPE
)
RETURNS VOID
LANGUAGE sql
SECURITY DEFINER
SET search_path = public, pg_temp
BEGIN ATOMIC
    DELETE FROM menu_item
    WHERE menu_item_id = p_menu_item_id
      AND menu_item_status_code = 'PND';
END;

COMMENT ON FUNCTION fn_delete_menu_item(integer) IS
'Deletes a menu item (database operation OP2).
 Parameter: p_menu_item_id = id of the item to delete.
 Preconditions: if the item does not exist or is not in status PND, zero rows are deleted.
 Related menu_item_category_assignment rows are removed automatically (ON DELETE CASCADE).';


-- OP3: activate a menu item (PND/INA -> ACT, requires at least one category)
CREATE OR REPLACE FUNCTION fn_activate_menu_item(
    p_menu_item_id menu_item.menu_item_id%TYPE,
    p_email        person.email%TYPE
)
RETURNS VOID
LANGUAGE sql
SECURITY DEFINER
SET search_path = public, pg_temp
BEGIN ATOMIC
    UPDATE menu_item AS mi
    SET menu_item_status_code = 'ACT',
        last_modified_at      = CURRENT_TIMESTAMP(0),
        last_modified_by_id   = e.person_id
    FROM employee AS e
        JOIN person AS p
            ON p.person_id = e.person_id
           AND lower(p.email) = lower(p_email)
        JOIN menu_item_status_type AS new_status
            ON new_status.menu_item_status_code = 'ACT'
           AND new_status.is_active = TRUE
    WHERE mi.menu_item_id = p_menu_item_id
      AND mi.menu_item_status_code IN ('PND', 'INA')
      AND EXISTS (
          SELECT 1
          FROM menu_item_category_assignment AS mica
          WHERE mica.menu_item_id = mi.menu_item_id
      );
END;

COMMENT ON FUNCTION fn_activate_menu_item(integer, varchar) IS
'Activates a menu item (database operation OP3).
 Parameters: p_menu_item_id = id of the item to activate; p_email = case-insensitive
 e-mail of the modifying employee.
 Preconditions: zero rows are updated if no employee has the given e-mail, if the item
 is not in status PND or INA, or if the item has no categories.';


-- OP4: deactivate a menu item (ACT -> INA)
CREATE OR REPLACE FUNCTION fn_deactivate_menu_item(
    p_menu_item_id menu_item.menu_item_id%TYPE,
    p_email        person.email%TYPE
)
RETURNS VOID
LANGUAGE sql
SECURITY DEFINER
SET search_path = public, pg_temp
BEGIN ATOMIC
    UPDATE menu_item AS mi
    SET menu_item_status_code = 'INA',
        last_modified_at      = CURRENT_TIMESTAMP(0),
        last_modified_by_id   = e.person_id
    FROM employee AS e
        JOIN person AS p
            ON p.person_id = e.person_id
           AND lower(p.email) = lower(p_email)
        JOIN menu_item_status_type AS new_status
            ON new_status.menu_item_status_code = 'INA'
           AND new_status.is_active = TRUE
    WHERE mi.menu_item_id = p_menu_item_id
      AND mi.menu_item_status_code = 'ACT';
END;

COMMENT ON FUNCTION fn_deactivate_menu_item(integer, varchar) IS
'Marks a menu item inactive (database operation OP4).
 Parameters: p_menu_item_id = id of the item; p_email = case-insensitive e-mail of the
 modifying employee.
 Preconditions: zero rows are updated if no employee has the given e-mail or the item
 is not in status ACT.';


-- OP5: discontinue a menu item (ACT/INA -> DSC)
CREATE OR REPLACE FUNCTION fn_discontinue_menu_item(
    p_menu_item_id menu_item.menu_item_id%TYPE,
    p_email        person.email%TYPE
)
RETURNS VOID
LANGUAGE sql
SECURITY DEFINER
SET search_path = public, pg_temp
BEGIN ATOMIC
    UPDATE menu_item AS mi
    SET menu_item_status_code = 'DSC',
        last_modified_at      = CURRENT_TIMESTAMP(0),
        last_modified_by_id   = e.person_id
    FROM employee AS e
        JOIN person AS p
            ON p.person_id = e.person_id
           AND lower(p.email) = lower(p_email)
        JOIN menu_item_status_type AS new_status
            ON new_status.menu_item_status_code = 'DSC'
           AND new_status.is_active = TRUE
    WHERE mi.menu_item_id = p_menu_item_id
      AND mi.menu_item_status_code IN ('ACT', 'INA');
END;

COMMENT ON FUNCTION fn_discontinue_menu_item(integer, varchar) IS
'Discontinues a menu item (database operation OP5).
 Parameters: p_menu_item_id = id of the item; p_email = case-insensitive e-mail of the
 modifying employee.
 Preconditions: zero rows are updated if no employee has the given e-mail or the item
 is not in status ACT or INA.';


-- OP6: update menu item data (only while PND/INA)
CREATE OR REPLACE FUNCTION fn_update_menu_item(
    p_old_menu_item_id    menu_item.menu_item_id%TYPE,
    p_new_menu_item_id    menu_item.menu_item_id%TYPE,
    p_name                menu_item.name%TYPE,
    p_description         menu_item.description%TYPE,
    p_price               menu_item.price%TYPE,
    p_calories            menu_item.calories%TYPE,
    p_menu_item_type_code menu_item.menu_item_type_code%TYPE,
    p_email               person.email%TYPE
)
RETURNS VOID
LANGUAGE sql
SECURITY DEFINER
SET search_path = public, pg_temp
BEGIN ATOMIC
    UPDATE menu_item AS mi
    SET menu_item_id        = p_new_menu_item_id,
        name                = p_name,
        description         = p_description,
        price               = p_price,
        calories            = p_calories,
        menu_item_type_code = p_menu_item_type_code,
        last_modified_at    = CURRENT_TIMESTAMP(0),
        last_modified_by_id = e.person_id
    FROM employee AS e
        JOIN person AS p
            ON p.person_id = e.person_id
           AND lower(p.email) = lower(p_email)
        JOIN menu_item_type AS mit
            ON mit.menu_item_type_code = p_menu_item_type_code
           AND mit.is_active = TRUE
    WHERE mi.menu_item_id = p_old_menu_item_id
      AND mi.menu_item_status_code IN ('PND', 'INA');
END;

COMMENT ON FUNCTION fn_update_menu_item(integer, integer, varchar, text, decimal, integer, char, varchar) IS
'Updates menu item data (database operation OP6).
 Parameters: p_old_menu_item_id = current id; p_new_menu_item_id = new id; p_name,
 p_description, p_price, p_calories = new values; p_menu_item_type_code = new type code;
 p_email = case-insensitive e-mail of the modifying employee.
 Preconditions: zero rows are updated if no employee has the given e-mail, if the item is
 not in status PND or INA, or if the item type is not active.';


-- OP7: add a menu item to a category (only while PND/INA)
CREATE OR REPLACE FUNCTION fn_add_menu_item_to_category(
    p_menu_item_id            menu_item.menu_item_id%TYPE,
    p_menu_item_category_code menu_item_category.menu_item_category_code%TYPE,
    p_email                   person.email%TYPE
)
RETURNS VOID
LANGUAGE sql
SECURITY DEFINER
SET search_path = public, pg_temp
BEGIN ATOMIC
    INSERT INTO menu_item_category_assignment (
        menu_item_id,
        menu_item_category_code
    )
    SELECT
        mi.menu_item_id,
        mic.menu_item_category_code
    FROM menu_item AS mi
        JOIN menu_item_category AS mic
            ON mic.menu_item_category_code = p_menu_item_category_code
           AND mic.is_active = TRUE
        JOIN employee AS e ON TRUE
        JOIN person   AS p
            ON p.person_id = e.person_id
           AND lower(p.email) = lower(p_email)
    WHERE mi.menu_item_id = p_menu_item_id
      AND mi.menu_item_status_code IN ('PND', 'INA');

    UPDATE menu_item AS mi
    SET last_modified_at    = CURRENT_TIMESTAMP(0),
        last_modified_by_id = e.person_id
    FROM employee AS e
        JOIN person AS p
            ON p.person_id = e.person_id
           AND lower(p.email) = lower(p_email)
    WHERE mi.menu_item_id = p_menu_item_id
      AND mi.menu_item_status_code IN ('PND', 'INA');
END;

COMMENT ON FUNCTION fn_add_menu_item_to_category(integer, char, varchar) IS
'Adds a menu item to a category (database operation OP7).
 Parameters: p_menu_item_id = item id; p_menu_item_category_code = category code;
 p_email = case-insensitive e-mail of the modifying employee.
 Preconditions: zero rows are inserted if no employee has the given e-mail, if the item
 is not in status PND or INA, or if the category is not active.';


-- OP8: remove a menu item from a category (only while PND/INA)
CREATE OR REPLACE FUNCTION fn_remove_menu_item_from_category(
    p_menu_item_id            menu_item.menu_item_id%TYPE,
    p_menu_item_category_code menu_item_category.menu_item_category_code%TYPE,
    p_email                   person.email%TYPE
)
RETURNS VOID
LANGUAGE sql
SECURITY DEFINER
SET search_path = public, pg_temp
BEGIN ATOMIC
    DELETE FROM menu_item_category_assignment AS mica
    USING menu_item AS mi
    WHERE mica.menu_item_id = mi.menu_item_id
      AND mica.menu_item_id = p_menu_item_id
      AND mica.menu_item_category_code = p_menu_item_category_code
      AND mi.menu_item_status_code IN ('PND', 'INA');

    UPDATE menu_item AS mi
    SET last_modified_at    = CURRENT_TIMESTAMP(0),
        last_modified_by_id = e.person_id
    FROM employee AS e
        JOIN person AS p
            ON p.person_id = e.person_id
           AND lower(p.email) = lower(p_email)
    WHERE mi.menu_item_id = p_menu_item_id
      AND mi.menu_item_status_code IN ('PND', 'INA');
END;

COMMENT ON FUNCTION fn_remove_menu_item_from_category(integer, char, varchar) IS
'Removes a menu item from a category (database operation OP8).
 Parameters: p_menu_item_id = item id; p_menu_item_category_code = category code to remove;
 p_email = case-insensitive e-mail of the modifying employee.
 Preconditions: zero rows are deleted if the item is not in status PND or INA, or if the
 assignment does not exist; the audit UPDATE matches zero rows if no employee has the
 given e-mail.';
