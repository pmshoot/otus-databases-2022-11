-- Отдельные роли для работы с БД.
-- Отдельные пользователи включаются в данные роли
CREATE ROLE ktm;
CREATE ROLE ktr;

-- Владелец БД администратор
CREATE DATABASE kinoteka OWNER dba;  -- database own by admin

-- connect to
\c kinoteka

-- владелей схемы и табличного пространства администратор
CREATE SCHEMA kinoteka AUTHORIZATION dba;
CREATE TABLESPACE fast_ts OWNER dba LOCATION '/home/pmike/postgres_storage';  -- fast tablespace

-- comments
COMMENT ON ROLE ktm is 'Role kinoteka Writer';
COMMENT ON ROLE ktr is 'Role kinoteka Reader';
COMMENT ON database kinoteka is 'БД КИНОТЕКА - Каталог данных о фильмах и сериалах для студентов изучающих современное искусство';

-- set permanent search_path to database kinoteka
ALTER DATABASE kinoteka SET search_path TO kinoteka;

-- grants
GRANT ALL PRIVILEGES ON DATABASE kinoteka TO ktm;
GRANT ALL PRIVILEGES ON TABLESPACE fast_ts TO ktm;
GRANT ALL PRIVILEGES ON SCHEMA kinoteka TO ktm;
GRANT USAGE ON SCHEMA kinoteka TO ktr;


