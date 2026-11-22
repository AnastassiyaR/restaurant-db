-- Installs the whole database. Run from this directory:
--   psql -d <database> -f install.sql
\set ON_ERROR_STOP on

\ir 01_schema/00_drop.sql
\ir 01_schema/01_people.sql
\ir 01_schema/02_employees.sql
\ir 01_schema/03_customers.sql
\ir 01_schema/04_menu.sql

\ir 02_views.sql
\ir 03_functions.sql
\ir 04_triggers.sql
\ir 05_sample_data.sql
