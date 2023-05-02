-- mysql sql

DROP TABLE IF EXISTS country;
CREATE TABLE country
(
    id    INT UNSIGNED NOT NULL auto_increment,
    code  CHAR(2)      NOT NULL UNIQUE comment 'Код страны',
    title VARCHAR(128) NOT NULL comment 'Наименование',
    PRIMARY KEY(id),
    CONSTRAINT country_code_title_unique UNIQUE (code, title)
) comment 'Каталог стран';

DROP TABLE IF EXISTS city;
CREATE TABLE city
(
    id         SERIAL PRIMARY KEY,
    title      VARCHAR(128) NOT NULL,
    country_id int(10)     NOT NULL REFERENCES country (id) ON DELETE RESTRICT,
    CONSTRAINT city_country_unique UNIQUE (title, country_id)
) comment 'Города';


DROP TABLE IF EXISTS genre;
CREATE TABLE genre
(
    id    INT UNSIGNED NOT NULL auto_increment PRIMARY KEY,
    title CHAR(128) NOT NULL UNIQUE
) comment 'Каталог жанров кинолент';

DROP TABLE IF EXISTS rars;
CREATE TABLE rars
(
    id          INT UNSIGNED NOT NULL AUTO_INCREMENT,
    title       VARCHAR(5) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL UNIQUE,
    min_age     SMALLINT   NOT NULL,
    description TEXT       NOT NULL,
    country     SMALLINT   NOT NULL REFERENCES country ON DELETE RESTRICT,
    CONSTRAINT rars_age_range_check CHECK ( min_age > 0 AND min_age < 19), 
    PRIMARY KEY (ID)
) comment 'Возрастная классификация информационной продукции';

DROP TABLE IF EXISTS movie;
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
    extra		   JSON comment 'Дополнительная информация',
    CONSTRAINT movie_rating_range_check CHECK (rating > 0 AND rating < 6),
    CONSTRAINT movie_duration_pos_check CHECK ( NULL OR duration >= 0 ),
    CONSTRAINT movie_budget_pos_check CHECK ( NULL OR budget >= 0 ),
    CONSTRAINT movie_release_date_check CHECK ( NULL OR NOT (EXTRACT(YEAR FROM release_date) > created_year OR
                                                             EXTRACT(YEAR FROM release_date) < created_year))
) comment'Каталог кинолент и сериалов';

DROP TABLE IF EXISTS movie_genre_m2m;
CREATE TABLE movie_genre_m2m
(
    id       INT UNSIGNED NOT NULL auto_increment PRIMARY KEY,
    genre_id SMALLINT NOT NULL REFERENCES genre ON DELETE CASCADE,
    movie_id INTEGER  NOT NULL REFERENCES movie ON DELETE CASCADE,
    CONSTRAINT movie_genre_unique UNIQUE (genre_id, movie_id)
) comment 'Отношения кинолент к жанрам';

DROP TABLE IF EXISTS person;
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
) comment 'Актеры, режиссеры,...';

DROP TABLE IF EXISTS person_position;
CREATE TABLE person_position
(
    id    INT UNSIGNED NOT NULL auto_increment PRIMARY KEY,
    title VARCHAR(128) NOT NULL UNIQUE
) comment 'Должности и выполняемые функции участников съемок';

DROP TABLE IF EXISTS movie_staff_m2m;
CREATE TABLE movie_staff_m2m
(
    id           SERIAL PRIMARY KEY,
    charact      VARCHAR(128),          -- исполняемая роль
    is_lead_role BOOL	  DEFAULT FALSE, -- главная роль
    position_id  SMALLINT NOT NULL REFERENCES person_position ON DELETE RESTRICT,
    person_id    INTEGER  NOT NULL REFERENCES person ON DELETE RESTRICT,
    movie_id     INTEGER  NOT NULL REFERENCES movie ON DELETE CASCADE
) comment 'Участники съемок';

DROP TABLE IF EXISTS place;
CREATE TABLE place
(
    id       INT UNSIGNED NOT NULL AUTO_INCREMENT,
    title    VARCHAR(128) NOT NULL,
    city_id  INTEGER      NOT NULL REFERENCES city ON DELETE RESTRICT,
    postcode VARCHAR(12)  NOT NULL,
    street   VARCHAR(128) NOT NULL,
    build    VARCHAR(5)   NOT NULL,
    office   VARCHAR(5),
    CONSTRAINT place_unique_constraint UNIQUE (city_id, postcode, street, build, office), 
    PRIMARY KEY (id)
) comment 'Места проведения награждений';

DROP TABLE IF EXISTS organization;
CREATE TABLE organization
(
    id          INT UNSIGNED NOT NULL auto_increment PRIMARY KEY,
    title       VARCHAR(128) NOT NULL comment 'Наименование',
    title_short VARCHAR(56)  NOT NULL comment 'Краткое наименование',
    place_id    BIGINT       NOT NULL REFERENCES place ON DELETE RESTRICT,
    ceo         INT      REFERENCES person ON DELETE SET NULL,
    found_at    DATE comment 'Дата основания',
    close_at    DATE comment 'Дата ликвидации'
) comment 'Каталог организаций юридических лиц';

DROP TABLE IF EXISTS film_award;
CREATE TABLE film_award
(
    id          serial PRIMARY KEY,
    founder     SMALLINT     NOT NULL REFERENCES organization ON DELETE RESTRICT,
    title       VARCHAR(128) NOT NULL,
    found_at    DATE         NOT NULL,
    ended_at    DATE,
    description TEXT
) comment 'Существующие кино-премии мира';

DROP TABLE IF EXISTS award_category;
CREATE TABLE award_category
(
    id            INT UNSIGNED NOT NULL auto_increment PRIMARY KEY,
    film_award_id SMALLINT     NOT NULL REFERENCES film_award ON DELETE RESTRICT,
    title         VARCHAR(128) NOT NULL,
    tier          SMALLINT     NOT NULL, -- класс награды
    CONSTRAINT award_category_tier_pos_check CHECK ( tier > 0 )
) comment 'Категория награды, относящаяся к кино-премии';

DROP TABLE IF EXISTS award_ceremony;
CREATE TABLE award_ceremony
(
    id            INT UNSIGNED NOT NULL auto_increment PRIMARY KEY,
    title         VARCHAR(128) NOT NULL,
    place_id      SMALLINT     NOT NULL REFERENCES place,
    film_award_id SMALLINT     NOT NULL REFERENCES film_award,
    start_at      DATE         NOT NULL,
    end_at        DATE
) comment 'Проведенные ежегодные церемонии награждения кино-премий';

DROP TABLE IF EXISTS award_nomination;
CREATE TABLE award_nomination
(
    id    INT UNSIGNED NOT NULL auto_increment PRIMARY KEY,
    title VARCHAR(128) NOT NULL UNIQUE
) comment 'Наименования существующих номинаций кино-премий';

DROP TABLE IF EXISTS award;
CREATE TABLE award
(
    id             SERIAL PRIMARY KEY,
    award_category SMALLINT NOT NULL REFERENCES award_category ON DELETE RESTRICT,
    ceremony_id    INTEGER  NOT NULL REFERENCES award_ceremony ON DELETE RESTRICT,
    movie_id       INTEGER  NOT NULL REFERENCES movie ON DELETE RESTRICT,
    person_id      INTEGER REFERENCES person ON DELETE RESTRICT,
    nomination_id  SMALLINT NOT NULL REFERENCES award_nomination ON DELETE RESTRICT,
    comments       TEXT,
    CONSTRAINT award_unique_constraint UNIQUE (ceremony_id, movie_id, nomination_id)
) comment 'Врученные награды кино-премий';

DROP TABLE IF EXISTS poster_pictures;
CREATE TABLE poster_pictures
(
    id        SERIAL PRIMARY KEY,
    file_path VARCHAR(128) NOT NULL,
    width     INTEGER      NOT NULL,
    height    INTEGER      NOT NULL
) comment 'Файлы изображений постеров';

DROP TABLE IF EXISTS movie_poster_m2m;
CREATE TABLE movie_poster_m2m
(
    id        SERIAL PRIMARY KEY,
    movie_id  INTEGER NOT NULL REFERENCES movie ON DELETE CASCADE,
    poster_id INTEGER NOT NULL REFERENCES poster_pictures ON DELETE CASCADE
) comment 'Постеры к фильмам';

DROP TABLE IF EXISTS person_poster_m2m;
CREATE TABLE person_poster_m2m
(
    id        SERIAL PRIMARY KEY,
    person_id INTEGER NOT NULL REFERENCES person ON DELETE CASCADE,
    poster_id INTEGER NOT NULL REFERENCES poster_pictures ON DELETE CASCADE
) comment 'Постеры с актерами';

DROP TABLE IF EXISTS tag;
CREATE TABLE tag
(
    id    SERIAL PRIMARY KEY,
    title VARCHAR(56) NOT NULL UNIQUE
) comment 'Теги';

DROP TABLE IF EXISTS users;
CREATE TABLE users
(
    id         serial PRIMARY KEY,
    username   VARCHAR(64)        NOT NULL UNIQUE,
    email      VARCHAR(128)       NOT NULL UNIQUE,
    passw      VARCHAR(128)       NOT NULL, -- password hash
    fio        VARCHAR(256)       NOT NULL,
    bio        TEXT,
    created_at DATE NOT NULL DEFAULT (CURRENT_DATE),
    deleted_at DATE,
    birthday   DATE          NOT NULL,
    last_logon DATE,
    CONSTRAINT user_check_created_less_deleted CHECK (users.created_at <= users.deleted_at)
) comment 'Пользователи кинотеки';

DROP TABLE IF EXISTS cinema_online;
CREATE TABLE cinema_online
(
    id    INT UNSIGNED NOT NULL auto_increment PRIMARY KEY,
    title VARCHAR(128) NOT NULL UNIQUE,
    url   VARCHAR(256)         NOT NULL UNIQUE
) comment 'Онлайн кинотеатры';

DROP TABLE IF EXISTS cinema_online_movie_presence;
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
) comment 'Наличие фильмов в онлайн-кинотеатрах';

DROP TABLE IF EXISTS user_movie_orders;
CREATE TABLE user_movie_orders
(
    id               SERIAL PRIMARY KEY,
    cinema_order_id  binary(16)               NOT NULL comment 'Идентификационный номер заказа в кинотеатре', -- uuid
    movie_id         INTEGER REFERENCES movie ON DELETE RESTRICT,
    user_id          INTEGER REFERENCES users ON DELETE RESTRICT,
    online_cinema_id INTEGER REFERENCES cinema_online ON DELETE RESTRICT,
    price            NUMERIC            NOT NULL CHECK ( price >= 0 ),
    order_date       DATE DEFAULT (CURRENT_DATE) NOT NULL,
    CONSTRAINT user_movie_orders_m2m_pk2 UNIQUE (user_id, movie_id, online_cinema_id)
) comment 'Заказы просмотров фильмов пользователями фильмов в онлайн-кинотеатрах';

DROP TABLE IF EXISTS publications_category;
CREATE TABLE publications_category
(
    id    SERIAL PRIMARY KEY,
    title VARCHAR(24) NOT NULL UNIQUE
) comment 'Категории публикаций (новости, обзор, анонс, ...)';

DROP TABLE IF EXISTS publications;
CREATE TABLE publications
(
    id          serial PRIMARY KEY,
    title       VARCHAR(256)                                                NOT NULL,
    content     TEXT                                                        NOT NULL,
	author      INTEGER REFERENCES users ON DELETE RESTRICT                 ,
    category    INTEGER REFERENCES publications_category ON DELETE RESTRICT ,
    create_date DATE DEFAULT (CURRENT_DATE)                                 NOT NULL,
    change_date DATE                                                        NOT NULL
) comment 'Публикации о кинематографе по категориям';

DROP TABLE IF EXISTS tag_m2m;
CREATE TABLE tag_m2m
(
    tag_id         INTEGER REFERENCES tag ON DELETE CASCADE,
    movie_id       INTEGER REFERENCES movie ON DELETE CASCADE,
    publication_id INTEGER REFERENCES publications ON DELETE CASCADE,
    CONSTRAINT tag_movie_unique UNIQUE (movie_id, tag_id),
    CONSTRAINT publication_movie_check
        CHECK (NOT (movie_id IS NULL AND publication_id IS NULL) OR
               NOT (movie_id IS NOT NULL AND publication_id IS NOT NULL))
) comment 'Теги фильмов и публикаций';

DROP TABLE IF EXISTS users_rating;
CREATE TABLE users_rating
(
    id             SERIAL PRIMARY KEY,
    rating         SMALLINT  NOT NULL,
    user_id        INTEGER   NOT NULL REFERENCES users ON DELETE CASCADE,
    movie_id       INTEGER REFERENCES movie ON DELETE CASCADE,
    publication_id BIGINT REFERENCES publications ON DELETE CASCADE,
    cur_date       TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT users_rating_unique_pk2 UNIQUE (movie_id, publication_id, user_id),
    CONSTRAINT user_rating_check_range_1_5 CHECK (rating > 0 AND rating < 6),
    CONSTRAINT user_comments_rating_check -- рейтинг только к фильму или публикации
        CHECK (NOT (movie_id IS NULL AND publication_id IS NULL) OR
               NOT (movie_id IS NOT NULL AND publication_id IS NOT NULL))
) comment 'Пользовательский рейтинг';

DROP TABLE IF EXISTS comments;
CREATE TABLE comments
(
    id             serial PRIMARY KEY,
    user_id        INTEGER            REFERENCES user ON DELETE SET NULL,
    note           TEXT               NOT NULL,
    parent_id      INTEGER REFERENCES comments ON DELETE RESTRICT,
    movie_id       INTEGER REFERENCES movie ON DELETE CASCADE,
    publication_id INTEGER REFERENCES publications ON DELETE CASCADE,
    create_date    DATE DEFAULT (CURRENT_DATE) NOT NULL,
    change_date    DATE,
    CONSTRAINT comments_on_movie_and_publication_check -- комментарий только к фильму или публикации
        CHECK (NOT (movie_id IS NULL AND publication_id IS NULL) OR
               NOT (movie_id IS NOT NULL AND publication_id IS NOT NULL))
) comment 'Комментарии пользователей';

-- INDEXES
-- одна кинопремия в год
CREATE UNIQUE INDEX award_ceremony_unique_idx ON award_ceremony (film_award_id, (EXTRACT(YEAR FROM start_at)));
CREATE INDEX movie_title_idx ON movie (title);
CREATE INDEX movie_title_original_idx ON movie (title_original);
CREATE INDEX movie_rating_idx ON movie (rating);
CREATE INDEX user_fio_idx ON users (fio);
CREATE INDEX person_name_idx ON person (last_name, first_name);
CREATE INDEX award_ceremony_title_idx ON award_ceremony (title);
CREATE INDEX publications_title_idx ON publications (title);
CREATE INDEX publications_create_date_idx ON publications (create_date);
