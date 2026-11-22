-- Estonian national ID must be exactly 11 digits
CREATE OR REPLACE FUNCTION fn_chk_estonian_national_id()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.country_code = 'EST'
       AND NEW.national_id !~ '^[[:digit:]]{11}$' THEN
        RAISE EXCEPTION
            'An Estonian national ID must consist of exactly 11 digits, got: %',
            NEW.national_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_person_ins_upd_chk_estonian_national_id
    BEFORE INSERT OR UPDATE ON person
    FOR EACH ROW EXECUTE FUNCTION fn_chk_estonian_national_id();


-- An employee's person_id may only change while PND or INA
CREATE OR REPLACE FUNCTION fn_chk_employee_person_id_change()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.person_id IS DISTINCT FROM NEW.person_id
       AND OLD.employee_status_code NOT IN ('PND', 'INA') THEN
        RAISE EXCEPTION
            'An employee''s person_id can only be changed while the status is PENDING or INACTIVE. Current status: %',
            OLD.employee_status_code;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_employee_upd_chk_person_id_change
    BEFORE UPDATE ON employee
    FOR EACH ROW EXECUTE FUNCTION fn_chk_employee_person_id_change();


-- Audit: set last_modified_at on update (person, user_account)
CREATE OR REPLACE FUNCTION fn_set_last_modified_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_modified_at = CURRENT_TIMESTAMP(0) AT TIME ZONE 'Europe/Tallinn';
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_person_upd_last_modified_at
    BEFORE UPDATE ON person
    FOR EACH ROW EXECUTE FUNCTION fn_set_last_modified_at();

CREATE TRIGGER tr_user_account_upd_last_modified_at
    BEFORE UPDATE ON user_account
    FOR EACH ROW EXECUTE FUNCTION fn_set_last_modified_at();


-- Audit: set registered_at / last_modified_at on insert
-- (menu_item, user_account)
CREATE OR REPLACE FUNCTION fn_set_registered_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.registered_at    = CURRENT_TIMESTAMP(0) AT TIME ZONE 'Europe/Tallinn';
    NEW.last_modified_at = CURRENT_TIMESTAMP(0) AT TIME ZONE 'Europe/Tallinn';
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_menu_item_ins_registered_at
    BEFORE INSERT ON menu_item
    FOR EACH ROW EXECUTE FUNCTION fn_set_registered_at();

CREATE TRIGGER tr_user_account_ins_registered_at
    BEFORE INSERT ON user_account
    FOR EACH ROW EXECUTE FUNCTION fn_set_registered_at();


-- A menu item cannot become ACTIVE without at least one category
CREATE OR REPLACE FUNCTION fn_chk_menu_item_has_category()
RETURNS TRIGGER AS $$
DECLARE
    v_category_count SMALLINT;
BEGIN
    IF NEW.menu_item_status_code = 'ACT'
       AND NEW.menu_item_status_code <> OLD.menu_item_status_code THEN
        SELECT COUNT(*) INTO v_category_count
        FROM menu_item_category_assignment
        WHERE menu_item_id = NEW.menu_item_id;

        IF v_category_count = 0 THEN
            RAISE EXCEPTION 'A menu item cannot be activated without a category!';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_menu_item_upd_chk_activation
    BEFORE UPDATE ON menu_item
    FOR EACH ROW EXECUTE FUNCTION fn_chk_menu_item_has_category();


-- A menu item can only be edited while PND or INA; stamps last_modified_at
CREATE OR REPLACE FUNCTION fn_chk_menu_item_editable()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.menu_item_status_code NOT IN ('PND', 'INA') THEN
        RAISE EXCEPTION
            'Menu item (id=%) cannot be modified because its status is %',
            NEW.menu_item_id, OLD.menu_item_status_code;
    END IF;
    NEW.last_modified_at = CURRENT_TIMESTAMP(0) AT TIME ZONE 'Europe/Tallinn';
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_menu_item_upd_chk_editable
    BEFORE UPDATE ON menu_item
    FOR EACH ROW EXECUTE FUNCTION fn_chk_menu_item_editable();


-- A menu item can only be deleted while PND
CREATE OR REPLACE FUNCTION fn_chk_menu_item_deletable()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.menu_item_status_code <> 'PND' THEN
        RAISE EXCEPTION 'A menu item can only be deleted while its status is PENDING!';
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_menu_item_del_chk_deletable
    BEFORE DELETE ON menu_item
    FOR EACH ROW EXECUTE FUNCTION fn_chk_menu_item_deletable();
