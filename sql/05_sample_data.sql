INSERT INTO person
    (national_id, country_code, email, person_status_code, birth_date, first_name, last_name, residence)
VALUES
    ('10000000001', 'EST', 'employee01@example.com', 'ACT', '1980-01-01', 'Employee', 'One',   '1 Sample Street, Sample City'),
    ('10000000002', 'EST', 'employee02@example.com', 'ACT', '1981-02-02', 'Employee', 'Two',   '2 Sample Street, Sample City'),
    ('10000000003', 'EST', 'employee03@example.com', 'ACT', '1982-03-03', 'Employee', 'Three', '3 Sample Street, Sample City'),
    ('10000000004', 'EST', 'employee04@example.com', 'ACT', '1983-04-04', 'Employee', 'Four',  '4 Sample Street, Sample City'),
    ('10000000005', 'EST', 'employee05@example.com', 'ACT', '1984-05-05', 'Employee', 'Five',  '5 Sample Street, Sample City'),
    ('10000000006', 'EST', 'employee06@example.com', 'PND', '1985-06-06', 'Employee', 'Six',   '6 Sample Street, Sample City'),
    ('10000000007', 'EST', 'employee07@example.com', 'ACT', '1986-07-07', 'Employee', 'Seven', '7 Sample Street, Sample City'),
    ('10000000008', 'EST', 'employee08@example.com', 'ACT', '1987-08-08', 'Employee', 'Eight', '8 Sample Street, Sample City'),
    ('10000000009', 'EST', 'employee09@example.com', 'INA', '1988-09-09', 'Employee', 'Nine',  '9 Sample Street, Sample City'),
    ('10000000010', 'EST', 'employee10@example.com', 'ACT', '1989-10-10', 'Employee', 'Ten',   '10 Sample Street, Sample City'),
    ('20000000011', 'EST', 'customer01@example.com', 'ACT', '1990-01-11', 'Customer', 'One',   '11 Sample Street, Sample City'),
    ('20000000012', 'EST', 'customer02@example.com', 'ACT', '1991-02-12', 'Customer', 'Two',   '12 Sample Street, Sample City'),
    ('PL-DEMO-000013',  'POL', 'customer03@example.com', 'ACT', '1992-03-13', 'Customer', 'Three', 'Sample City, Poland'),
    ('ENG-DEMO-000014', 'ENG', 'customer04@example.com', 'ACT', '1993-04-14', 'Customer', 'Four',  'Sample City, England'),
    ('20000000015', 'EST', 'customer05@example.com', 'ACT', '1994-05-15', 'Customer', 'Five',  '15 Sample Street, Sample City');


INSERT INTO user_account (person_id, password, is_active) VALUES
    ( 1, 'demo-password-01', TRUE),
    ( 2, 'demo-password-02', TRUE),
    ( 3, 'demo-password-03', TRUE),
    ( 4, 'demo-password-04', TRUE),
    ( 5, 'demo-password-05', TRUE),
    ( 6, 'demo-password-06', FALSE),
    ( 7, 'demo-password-07', TRUE),
    ( 8, 'demo-password-08', TRUE),
    (11, 'demo-password-11', TRUE),
    (12, 'demo-password-12', TRUE);


INSERT INTO employee (person_id, employee_status_code, mentor_id) VALUES
    ( 1, 'ACT', NULL),
    ( 2, 'ACT', 1),
    ( 3, 'ACT', 1),
    ( 4, 'ACT', 2),
    ( 5, 'ACT', 2),
    ( 6, 'PND', 1),
    ( 7, 'ACT', 3),
    ( 8, 'ACT', 3),
    ( 9, 'INA', 1),
    (10, 'ACT', 2);


INSERT INTO employee_role_assignment (employee_role_code, start_time, end_time, person_id) VALUES
    ('HDC', '2022-01-01 08:00:00+02', 'infinity',                 1),
    ('CHF', '2022-03-01 08:00:00+02', 'infinity',                 2),
    ('CHF', '2021-06-01 08:00:00+02', 'infinity',                 3),
    ('WTR', '2023-01-15 08:00:00+02', 'infinity',                 4),
    ('BAR', '2022-09-01 08:00:00+02', 'infinity',                 5),
    ('WTR', '2023-05-01 08:00:00+02', '2024-05-01 08:00:00+02',   6),
    ('SHS', '2021-01-01 08:00:00+02', 'infinity',                 7),
    ('CLN', '2023-03-01 08:00:00+02', 'infinity',                 8),
    ('CHF', '2020-01-01 08:00:00+02', '2023-01-01 08:00:00+02',   9),
    ('WTR', '2024-01-01 08:00:00+02', 'infinity',                10);


INSERT INTO customer (person_id, customer_status_code, consents_to_data_processing) VALUES
    (11, 'ACT', TRUE),
    (12, 'ACT', FALSE),
    (13, 'ACT', TRUE),
    (14, 'INA', FALSE),
    (15, 'ACT', TRUE);


INSERT INTO menu_item (
    menu_item_id, name, description, price, calories,
    menu_item_status_code, menu_item_type_code, registered_by_id, last_modified_by_id
) VALUES
    ( 1, 'Borscht',            'Traditional beetroot soup with sour cream',        5.50, 320, 'ACT', 'FOD', 1, 1),
    ( 2, 'Caesar salad',       'Romaine lettuce with croutons and parmesan',       7.90, 410, 'ACT', 'FOD', 1, 1),
    ( 3, 'Grilled chicken',    'Marinated grilled chicken',                       12.50, 580, 'ACT', 'FOD', 1, 2),
    ( 4, 'Salmon fillet',      'Oven-baked salmon fillet with herbs',             15.90, 520, 'ACT', 'FOD', 2, 2),
    ( 5, 'Vegetable pasta',    'Vegetable pasta in tomato sauce',                  9.50, 480, 'PND', 'FOD', 2, 2),
    ( 6, 'Coffee',             'Espresso from arabica beans',                      2.50,  10, 'ACT', 'DRK', 3, 3),
    ( 7, 'Orange juice',       'Freshly squeezed orange juice',                    3.90, 120, 'ACT', 'DRK', 3, 3),
    ( 8, 'Lemonade',           'Homemade lemonade with mint',                      3.50,  95, 'ACT', 'DRK', 3, 4),
    ( 9, 'Chocolate cake',     'Chocolate cake with vanilla ice cream',            5.90, 620, 'ACT', 'FOD', 4, 4),
    (10, 'Cheese platter',     'A selection of local and European cheeses',       11.50, 540, 'INA', 'FOD', 4, 4),
    (11, 'Tomato soup',        'Creamy tomato soup with basil',                    5.90, 280, 'ACT', 'FOD', 5, 5),
    (12, 'Beer',               'Local craft beer, 0.5 L',                          4.50, 210, 'ACT', 'DRK', 5, 5),
    (13, 'Water',              'Sparkling mineral water, 0.5 L',                   2.00,   0, 'ACT', 'DRK', 1, 1),
    (14, 'Mixed nuts',         'Roasted mixed nuts',                               3.50, 580, 'PND', 'OTH', 1, 1),
    (15, 'Lasagne',            'Classic lasagne with meat sauce',                 13.50, 650, 'ACT', 'FOD', 2, 3);


INSERT INTO menu_item_category_assignment (menu_item_id, menu_item_category_code) VALUES
    ( 1, 'VEG'),
    ( 2, 'GLT'),
    ( 2, 'EGG'),
    ( 3, 'MEA'),
    ( 4, 'FSH'),
    ( 5, 'GLT'),
    ( 5, 'VEG'),
    ( 9, 'GLT'),
    ( 9, 'EGG'),
    ( 9, 'LAC'),
    (10, 'LAC'),
    (11, 'VEG'),
    (14, 'NUT'),
    (15, 'GLT'),
    (15, 'MEA');
