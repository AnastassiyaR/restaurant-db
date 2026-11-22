CREATE OR REPLACE VIEW menu_item_details
    WITH (security_barrier) AS
SELECT
    mi.menu_item_id,
    mi.name                                   AS menu_item_name,
    mit.name                                  AS menu_item_type,
    mist.name                                 AS current_status,
    mi.price,
    mi.calories,
    mi.description                            AS menu_item_description,
    reg.email::text || ' ('
        || btrim(COALESCE(reg.first_name, '') || ' ' || COALESCE(reg.last_name, ''))
        || ')'                                AS registered_by,
    upd.email::text || ' ('
        || btrim(COALESCE(upd.first_name, '') || ' ' || COALESCE(upd.last_name, ''))
        || ')'                                AS last_modified_by,
    to_char(mi.registered_at,    'DD.MM.YYYY HH24:MI:SS') AS registered_at,
    to_char(mi.last_modified_at, 'DD.MM.YYYY HH24:MI:SS') AS last_modified_at
FROM menu_item mi
    JOIN menu_item_type        mit  ON mit.menu_item_type_code    = mi.menu_item_type_code
    JOIN menu_item_status_type mist ON mist.menu_item_status_code = mi.menu_item_status_code
    JOIN employee              reg_e ON reg_e.person_id           = mi.registered_by_id
    JOIN person                reg   ON reg.person_id             = reg_e.person_id
    JOIN employee              upd_e ON upd_e.person_id           = mi.last_modified_by_id
    JOIN person                upd   ON upd.person_id             = upd_e.person_id
ORDER BY mi.menu_item_id;


CREATE OR REPLACE VIEW active_and_inactive_menu_items
    WITH (security_barrier) AS
SELECT
    mi.menu_item_id,
    mi.name        AS menu_item_name,
    mit.name       AS menu_item_type,
    mist.name      AS current_status,
    mi.price,
    mi.calories
FROM menu_item_status_type mist
    JOIN (menu_item_type mit
          JOIN menu_item mi ON mit.menu_item_type_code = mi.menu_item_type_code)
        ON mist.menu_item_status_code = mi.menu_item_status_code
WHERE mi.menu_item_status_code = ANY (ARRAY['ACT', 'INA'])
ORDER BY mi.menu_item_id;


CREATE OR REPLACE VIEW menu_item_status_summary
    WITH (security_barrier) AS
SELECT
    mist.menu_item_status_code,
    upper(mist.name::text)          AS status_name,
    count(mi.menu_item_id)          AS menu_item_count
FROM menu_item_status_type mist
    LEFT JOIN menu_item mi ON mist.menu_item_status_code = mi.menu_item_status_code
GROUP BY mist.menu_item_status_code, upper(mist.name::text)
ORDER BY count(mi.menu_item_id) DESC, upper(mist.name::text);


CREATE OR REPLACE VIEW menu_item_categories
    WITH (security_barrier) AS
SELECT
    mica.menu_item_id,
    mic.name::text || ' (' || mict.name::text || ')' AS category
FROM menu_item_category_type mict
    JOIN (menu_item_category mic
          JOIN menu_item_category_assignment mica
              ON mic.menu_item_category_code = mica.menu_item_category_code)
        ON mict.menu_item_category_type_code = mic.menu_item_category_type_code;
