-- postgres sql

BEGIN;

---
CREATE TABLE country
(
    id    SMALLSERIAL PRIMARY KEY,
    code  CHAR(2)      NOT NULL UNIQUE,
    title VARCHAR(128) NOT NULL,
    CONSTRAINT country_code_title_unique UNIQUE (code, title)
);
COMMENT ON TABLE country IS 'Каталог стран';
COMMENT ON COLUMN country.code IS 'Код страны';
COMMENT ON COLUMN country.title IS 'Наименование';

---
CREATE TABLE city
(
    id         SERIAL PRIMARY KEY,
    title      VARCHAR(128) NOT NULL,
    country_id SMALLINT     NOT NULL REFERENCES country (id) ON DELETE RESTRICT,
    CONSTRAINT city_country_unique UNIQUE (title, country_id)
);
COMMENT ON TABLE city IS 'Города';

---
CREATE TABLE genre
(
    id    SMALLSERIAL PRIMARY KEY,
    title CHAR(128) NOT NULL UNIQUE
);
COMMENT ON TABLE genre IS 'Каталог жанров кинолент';

---
CREATE TABLE rars
(
    id          SMALLSERIAL PRIMARY KEY,
    title       VARCHAR(5) NOT NULL UNIQUE,
    min_age     SMALLINT   NOT NULL,
    description TEXT       NOT NULL,
    country     SMALLINT   NOT NULL REFERENCES country ON DELETE RESTRICT,
    CONSTRAINT rars_age_range_check CHECK ( min_age > 0 AND min_age < 19)
);
COMMENT ON TABLE rars IS 'Возрастная классификация информационной продукции';

---
CREATE TABLE movie
(
    id             SERIAL PRIMARY KEY,
    title          VARCHAR(128) NOT NULL,
    title_original VARCHAR(128),
    country        SMALLINT     NOT NULL REFERENCES country,
    "year"         SMALLINT     NOT NULL,
    release_date   DATE,
    budget         NUMERIC,
    boxoffice      NUMERIC,
    rating         SMALLINT,
    duration       INTEGER      NOT NULL,
    rars           VARCHAR(5) REFERENCES rars (title) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT movie_rating_range_check CHECK (rating > 0 AND rating < 6),
    CONSTRAINT movie_duration_pos_check CHECK ( NULL OR duration >= 0 ),
    CONSTRAINT movie_budget_pos_check CHECK ( NULL OR budget >= 0 ),
    CONSTRAINT movie_release_date_check CHECK ( NULL OR NOT (EXTRACT(YEAR FROM release_date) > "year" OR
                                                             EXTRACT(YEAR FROM release_date) < "year"))
);
COMMENT ON TABLE movie IS 'Каталог кинолент и сериалов';

---
CREATE TABLE movie_genre_m2m
(
    id       SERIAL PRIMARY KEY,
    genre_id SMALLINT NOT NULL REFERENCES genre ON DELETE CASCADE,
    movie_id INTEGER  NOT NULL REFERENCES movie ON DELETE CASCADE,
    CONSTRAINT movie_genre_unique UNIQUE (genre_id, movie_id)
);
COMMENT ON TABLE movie_genre_m2m IS 'Отношения кинолент к жанрам';

---
CREATE TABLE person
(
    id         SERIAL PRIMARY KEY,
    last_name  VARCHAR(128) NOT NULL,
    first_name VARCHAR(128) NOT NULL,
    mid_name   VARCHAR(128),
    city_id    INTEGER REFERENCES city ON DELETE RESTRICT,
    birthday   DATE,
    education  VARCHAR(128),
    bio        TEXT
);
COMMENT ON TABLE person IS 'Актеры, режиссеры,...';

---
CREATE TABLE person_position
(
    id    SMALLSERIAL PRIMARY KEY,
    title VARCHAR(128) NOT NULL UNIQUE
);
COMMENT ON TABLE person_position IS 'Должности и выполняемые функции участников съемок';

CREATE TABLE movie_staff_m2m
(
    id           SERIAL PRIMARY KEY,
    "character"  VARCHAR(128),          -- исполняемая роль
    is_lead_role BOOLEAN DEFAULT FALSE, -- главная роль
    position_id  SMALLINT NOT NULL REFERENCES person_position ON DELETE RESTRICT,
    person_id    INTEGER  NOT NULL REFERENCES person ON DELETE RESTRICT,
    movie_id     INTEGER  NOT NULL REFERENCES movie ON DELETE CASCADE
);
COMMENT ON TABLE movie_staff_m2m IS 'Участники съемок';

---
CREATE TABLE place
(
    id       SMALLSERIAL PRIMARY KEY,
    title    VARCHAR(128) NOT NULL,
    city_id  INTEGER      NOT NULL REFERENCES city ON DELETE RESTRICT,
    postcode VARCHAR(12)  NOT NULL,
    street   VARCHAR(128) NOT NULL,
    build    VARCHAR(5)   NOT NULL,
    office   VARCHAR(5),
    CONSTRAINT place_unique_constraint UNIQUE (city_id, postcode, street, build, office)
);
COMMENT ON TABLE place IS 'Места проведения награждений';

---
CREATE TABLE organization
(
    id          SMALLSERIAL PRIMARY KEY,
    title       VARCHAR(128) NOT NULL,
    title_short VARCHAR(56)  NOT NULL,
    place_id    INTEGER      NOT NULL REFERENCES place ON DELETE RESTRICT,
    ceo         INTEGER      REFERENCES person ON DELETE SET NULL,
    found_at    DATE,
    close_at    DATE
);
COMMENT ON TABLE organization IS 'Каталог организаций юридических лиц';
COMMENT ON COLUMN organization.title IS 'Наименование';
COMMENT ON COLUMN organization.title_short IS 'Краткое наименование';
COMMENT ON COLUMN organization.place_id IS 'Штаб-квартира';
COMMENT ON COLUMN organization.ceo IS 'Шеф';
COMMENT ON COLUMN organization.found_at IS 'Дата основания';

---
CREATE TABLE film_award
(
    id          SMALLSERIAL PRIMARY KEY,
    founder     SMALLINT     NOT NULL REFERENCES organization ON DELETE RESTRICT,
    title       VARCHAR(128) NOT NULL,
    found_at    DATE         NOT NULL,
    ended_at    DATE,
    description TEXT
);
COMMENT ON TABLE film_award IS 'Существующие кино-премии мира';

---
CREATE TABLE award_category
(
    id            SMALLSERIAL PRIMARY KEY,
    film_award_id SMALLINT     NOT NULL REFERENCES film_award ON DELETE RESTRICT,
    title         VARCHAR(128) NOT NULL,
    tier          SMALLINT     NOT NULL, -- класс награды
    CONSTRAINT award_category_tier_pos_check CHECK ( tier > 0 )
);
COMMENT ON TABLE award_category IS 'Категория награды, относящаяся к кино-премии';

---
CREATE TABLE award_ceremony
(
    id            INTEGER PRIMARY KEY,
    title         VARCHAR(128) NOT NULL,
    place_id      SMALLINT     NOT NULL REFERENCES place,
    film_award_id SMALLINT     NOT NULL REFERENCES film_award,
    start_at      DATE         NOT NULL,
    end_at        DATE
);
COMMENT ON TABLE award_ceremony IS 'Проведенные ежегодные церемонии награждения кино-премий';

---
CREATE TABLE award_nomination
(
    id    SMALLSERIAL PRIMARY KEY,
    title VARCHAR(128) NOT NULL UNIQUE
);
COMMENT ON TABLE award_nomination IS 'Наименования существующих номинаций кино-премий';

---
CREATE TABLE award
(
    id             SERIAL PRIMARY KEY,
    award_category SMALLINT NOT NULL REFERENCES award_category ON DELETE RESTRICT,
    ceremony_id    INTEGER  NOT NULL REFERENCES award_ceremony ON DELETE RESTRICT,
    movie_id       INTEGER  NOT NULL REFERENCES movie ON DELETE RESTRICT,
    person_id      INTEGER REFERENCES person ON DELETE RESTRICT,
    nomination_id  SMALLINT NOT NULL REFERENCES award_nomination ON DELETE RESTRICT,
    "comment"      TEXT,
    CONSTRAINT award_unique_constraint UNIQUE (ceremony_id, movie_id, nomination_id)
);
COMMENT ON TABLE award IS 'Врученные награды кино-премий';

---
CREATE TABLE poster_pictures
(
    id        SERIAL PRIMARY KEY,
    file_path VARCHAR(128) NOT NULL,
    width     INTEGER      NOT NULL,
    height    INTEGER      NOT NULL
);
COMMENT ON TABLE poster_pictures IS 'Файлы изображений постеров';

---
CREATE TABLE movie_poster_m2m
(
    id        SERIAL PRIMARY KEY,
    movie_id  INTEGER NOT NULL REFERENCES movie ON DELETE CASCADE,
    poster_id INTEGER NOT NULL REFERENCES poster_pictures ON DELETE CASCADE
);
COMMENT ON TABLE movie_poster_m2m IS 'Постеры к фильмам';

---
CREATE TABLE person_poster_m2m
(
    id        SERIAL PRIMARY KEY,
    person_id INTEGER NOT NULL REFERENCES person ON DELETE CASCADE,
    poster_id INTEGER NOT NULL REFERENCES poster_pictures ON DELETE CASCADE
);
COMMENT ON TABLE person_poster_m2m IS 'Постеры с актерами';

CREATE TABLE tag
(
    id    SERIAL PRIMARY KEY,
    title VARCHAR(56) NOT NULL UNIQUE
);
COMMENT ON TABLE tag IS 'Теги';

---
CREATE TABLE "user"
(
    id         SERIAL PRIMARY KEY,
    username   VARCHAR(64)        NOT NULL UNIQUE,
    email      VARCHAR(128)       NOT NULL UNIQUE,
    "password" VARCHAR(128)       NOT NULL, -- password hash
    fio        VARCHAR(256)       NOT NULL,
    bio        TEXT,
    created_at DATE DEFAULT NOW() NOT NULL,
    deleted_at DATE,
    birthday   DATE               NOT NULL,
    last_logon DATE,
    CONSTRAINT user_birthday_check CHECK (birthday < NOW()),
    CONSTRAINT user_check_created_less_deleted CHECK ("user".created_at <= "user".deleted_at)
);
COMMENT ON TABLE "user" IS 'Пользователи кинотеки';

---
CREATE TABLE cinema_online
(
    id    SERIAL PRIMARY KEY,
    title VARCHAR(128) NOT NULL UNIQUE,
    url   TEXT         NOT NULL UNIQUE
);
COMMENT ON TABLE cinema_online IS 'Онлайн кинотеатры';

---
CREATE TABLE cinema_online_movie_presence
(
    id          SERIAL PRIMARY KEY,
    movie_id    INTEGER REFERENCES movie ON DELETE CASCADE,
    cinema_id   INTEGER REFERENCES cinema_online ON DELETE CASCADE,
    price       NUMERIC NOT NULL,
    rating      INTEGER NOT NULL,
    discount    SMALLINT DEFAULT 0 CHECK ( discount >= 0 OR discount <= 100 ), -- скидка для студентов
    view_count  INTEGER,
    last_update DATE,
    CONSTRAINT movie_cinema_rating_check CHECK (rating > 0 AND rating < 6),
    CONSTRAINT cinema_online_movie_presence_unique UNIQUE (movie_id, cinema_id)
);
COMMENT ON TABLE cinema_online_movie_presence IS 'Наличие фильмов в онлайн-кинотеатрах';

---
CREATE TABLE user_movie_orders
(
    id               SERIAL PRIMARY KEY,
    cinema_order_id  uuid               NOT NULL,
    movie_id         INTEGER REFERENCES movie ON DELETE RESTRICT,
    user_id          INTEGER REFERENCES "user" ON DELETE RESTRICT,
    online_cinema_id INTEGER REFERENCES cinema_online ON DELETE RESTRICT,
    price            NUMERIC            NOT NULL CHECK ( price >= 0 ),
    "date"           DATE DEFAULT NOW() NOT NULL,
    CONSTRAINT user_movie_orders_m2m_pk2 UNIQUE (user_id, movie_id, online_cinema_id)
);
COMMENT ON TABLE user_movie_orders IS 'Заказы просмотров фильмов пользователями фильмов в онлайн-кинотеатрах';
COMMENT ON COLUMN user_movie_orders.cinema_order_id IS 'Идентификационный номер заказа в кинотеатре';

---
CREATE TABLE publications_category
(
    id    SERIAL PRIMARY KEY,
    title VARCHAR(24) NOT NULL UNIQUE
);
COMMENT ON TABLE publications_category IS 'Категории публикаций (новости, обзор, анонс, ...)';

--- Публикации, обзоры, критика пользователей (студентов и преподавателей)
CREATE TABLE publications
(
    id          BIGSERIAL PRIMARY KEY,
    title       VARCHAR(256)                                                NOT NULL,
    "text"      TEXT                                                        NOT NULL,
    author      INTEGER REFERENCES "user" ON DELETE RESTRICT                NOT NULL,
    "category"  INTEGER REFERENCES publications_category ON DELETE RESTRICT NOT NULL,
    create_date DATE DEFAULT NOW()                                          NOT NULL,
    change_date DATE                                                        NOT NULL
)
    TABLESPACE fast_ts; -- fast table spase
COMMENT ON TABLE publications IS 'Публикации о кинематографе по категориям';

---
CREATE TABLE tag_m2m
(
    tag_id         INTEGER REFERENCES tag ON DELETE CASCADE,
    movie_id       INTEGER REFERENCES movie ON DELETE CASCADE,
    publication_id INTEGER REFERENCES publications ON DELETE CASCADE,
    CONSTRAINT tag_movie_unique UNIQUE (movie_id, tag_id),
    CONSTRAINT publication_movie_check
        CHECK (NOT (movie_id IS NULL AND publication_id IS NULL) OR
               NOT (movie_id IS NOT NULL AND publication_id IS NOT NULL))
)
    TABLESPACE fast_ts; -- fast table spase
COMMENT ON TABLE tag_m2m IS 'Теги фильмов и публикаций';

---
CREATE TABLE users_rating
(
    id             SERIAL PRIMARY KEY,
    rating         SMALLINT  NOT NULL,
    user_id        INTEGER   NOT NULL REFERENCES "user" ON DELETE CASCADE,
    movie_id       INTEGER REFERENCES movie ON DELETE CASCADE,
    publication_id BIGINT REFERENCES publications ON DELETE CASCADE,
    "date"         TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT users_rating_unique_pk2 UNIQUE (movie_id, publication_id, user_id),
    CONSTRAINT user_rating_check_range_1_5 CHECK (rating > 0 AND rating < 6),
    CONSTRAINT user_comments_rating_check -- рейтинг только к фильму или публикации
        CHECK (NOT (movie_id IS NULL AND publication_id IS NULL) OR
               NOT (movie_id IS NOT NULL AND publication_id IS NOT NULL))
)
    TABLESPACE fast_ts; -- fast table spase
COMMENT ON TABLE users_rating IS 'Пользовательский рейтинг';

---
CREATE TABLE comments
(
    id             BIGSERIAL PRIMARY KEY,
    user_id        INTEGER            REFERENCES "user" ON DELETE SET NULL,
    "comment"      TEXT               NOT NULL,
    parent_id      INTEGER REFERENCES comments ON DELETE RESTRICT,
    movie_id       INTEGER REFERENCES movie ON DELETE CASCADE,
    publication_id INTEGER REFERENCES publications ON DELETE CASCADE,
    create_date    DATE DEFAULT NOW() NOT NULL,
    change_date    DATE,
    CONSTRAINT comments_on_movie_and_publication_check -- комментарий только к фильму или публикации
        CHECK (NOT (movie_id IS NULL AND publication_id IS NULL) OR
               NOT (movie_id IS NOT NULL AND publication_id IS NOT NULL))
)
    TABLESPACE fast_ts;
COMMENT ON TABLE comments IS 'Комментарии пользователей';

-- INDEXES

-- одна кинопремия в год
CREATE UNIQUE INDEX award_ceremony_unique_idx ON award_ceremony (film_award_id, EXTRACT(YEAR FROM start_at));
CREATE INDEX movie_title_idx ON movie (title);
CREATE INDEX movie_title_original_idx ON movie (title_original);
CREATE INDEX movie_rating_idx ON movie (rating);
CREATE INDEX user_fio_idx ON "user" (fio);
CREATE INDEX person_name_idx ON person (last_name, first_name);
CREATE INDEX award_ceremony_title_idx ON award_ceremony (title);
CREATE INDEX publications_title_idx ON publications (title) TABLESPACE fast_ts;
CREATE INDEX publications_text_idx ON publications ("text") TABLESPACE fast_ts; -- todo: add FTS
CREATE INDEX publications_create_date_idx ON publications (create_date) TABLESPACE fast_ts;

COMMIT;