#ДЗ 10: Mysql типы данных

1. Анализ данных проекта "Кинотека".  [DDL схема данных](create_tables.sql)

Для создания таблиц в БД Mysql за прототип была взята уже созданная ранее [схема для Postgres](https://github.com/pmshoot/otus-databases-2022-11/blob/master/lessons/01/ddl.sql). Изменений в схеме в отношении типов данных делать почти не пришлось, благодаря стандарту:

- `SMALLSERIAL`, `SERIAL` в PG для автоинкремента первичного ключа и `INT UNSIGNED NOT NULL AUTO_INCREMENT` и `SERIAL` в Mysql

Основные изменения коснулись:

- комментарии - синтаксис
- constraint: в Mysq не удалось использовать `CURRENT_DATE` при создании CONSTRAINT на проверку даты
- формулы: `NOW()` - PG, `CURRENT_DATE` - MySQL
- транзакция при создании таблиц (PG поддерживает, Mysql нет)

2. Добавить тип JSON в структуру

В таблицу `movie` добавлен поле `extra` тип JSON:

```sql
CREATE TABLE movie
(
    id             SERIAL PRIMARY KEY,
    title          VARCHAR(128) NOT NULL,
    title_original VARCHAR(128),
    country        SMALLINT     NOT NULL REFERENCES country,
    created_year   SMALLINT     NOT NULL,
    release_date   DATE,
    budget         NUMERIC,
    boxoffice      NUMERIC,
    rating         SMALLINT,
    duration       INTEGER      NOT NULL,
    rars           VARCHAR(5) REFERENCES rars (title) ON UPDATE CASCADE ON DELETE RESTRICT,
    extra		   JSON comment 'Дополнительная информация'
    ;
```

Один из плюсов JSON - не фиксированная структура и большая вариативность хранимых данных. В JSON можно хранить данные, структура которых может отличаться от записи к записи. Например дополнительные поля к характеристикам или свойствам объекта.

```sql
INSERT INTO country (code, title) VALUES
('RU', 'Россия'),
('US', 'США'),
('CH', 'Китай');

INSERT INTO rars (title, description, min_age, country) VALUES
('R', 'лицам до 17 лет обязательно присутствие взрослого', 10, 2),
('12+', 'Возрастное ограничение 12 лет', 12, 1)
;

INSERT INTO movie (title, title_original,  country, created_year, duration, rars, extra) VALUES
('Джон Уик 4', 'John Wick: Chapter 4', 2, 2023, 169, 1, '{"world_premier": "13 марта 2023", "russia_premier": "23 марта 2023", "slogan": "Baba Yaga"}'),
('Вызов', NULL, 1, 2023, 164, 2, '{"world_premier": "20 апреля 2023", "russia_premier": "20 апреля 2023, «Централ Партнершип»"}'),
('В погоне за счастьем', 'The Pursuit of Happyness', 2, 2006, 117, 2, '{"world_premier": "15 декабря 2006", "russia_premier": "22 марта 2007, «Каскад фильм»", "DVD-release": "7 апреля 2007, «Columbia/Sony»", "BR-release": "19 июля 2007, «Columbia/Sony»"}')
;
```

В данном случае были добавлены некоторые характеристки к кинокартинам.
