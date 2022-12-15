/*

Проект базы данных "Кинотека"

*/

drop database if exists kinoteka;

create database kinoteka;

-- Полученные награды (фильм, актер, режиссер,..) на церемониях вручения по номинациям
CREATE TABLE award
(
 id             bigint NOT NULL,
 award_category integer NOT NULL,           -- категория награды (золотая, серебряная статуэтки оскар, золотая пальмовая ветвь ...)
 ceremony_id    bigint NOT NULL,            -- церемония награждения
 movie_id       bigint NOT NULL,            -- за какой фильм, сериал
 person_id      bigint NULL,                -- актеру, режиссеру, композитору или NULL за фильм
 nomitation_id  bigint NOT NULL,            -- в номинации

 CONSTRAINT pk_award PRIMARY KEY ( id ),
 CONSTRAINT fk_award_nomination FOREIGN KEY ( nomitation_id ) REFERENCES award_nomination ( id ),
 CONSTRAINT fk_movie FOREIGN KEY ( movie_id ) REFERENCES movie ( id ),
 CONSTRAINT fk_persin FOREIGN KEY ( person_id ) REFERENCES person ( id ),
 CONSTRAINT fk_award_ceremony FOREIGN KEY ( ceremony_id ) REFERENCES award_ceremony ( id ),
 CONSTRAINT fk_award_category FOREIGN KEY ( award_category ) REFERENCES award_category ( id )
);

--
CREATE TABLE award_category
(
 id            integer NOT NULL,
 title          NOT NULL,
 film_award_id bigint NOT NULL,
 tier          integer NOT NULL,

 CONSTRAINT PK_1 PRIMARY KEY ( id ),
 CONSTRAINT FK_19 FOREIGN KEY ( film_award_id ) REFERENCES film_award ( id )
);

-- Церемонии награждения
CREATE TABLE award_ceremony
(
 id                bigint NOT NULL,
 title             char(128) NOT NULL,      -- наименование
 place_id          bigint NOT NULL,         -- место проведения
 award_category_id bigint NOT NULL,         -- категория кинопремии (оскар, канны, ника)
 start_at          date NOT NULL,           -- дата начала
 end_at            date NOT NULL,           -- дата окончания

 CONSTRAINT pk_award_ceremony PRIMARY KEY ( id ),
 CONSTRAINT pk_film_award FOREIGN KEY ( award_category_id ) REFERENCES film_award ( id ),
 CONSTRAINT pk_place FOREIGN KEY ( place_id ) REFERENCES place ( id )
);

-- Учредитель кинопремии
CREATE TABLE award_founder
(
 id      integer NOT NULL,
 title   char(128) NOT NULL,                -- наименование
 country char(2) NOT NULL,                  -- страна

 CONSTRAINT pk_award_founder PRIMARY KEY ( id ),
 CONSTRAINT fk_countries FOREIGN KEY ( country ) REFERENCES countries ( id )
);

-- Номинации кинопремий
CREATE TABLE award_nomination
(
 id         bigint NOT NULL,
 title      varchar NOT NULL,               -- наименование
 subject_id integer NOT NULL,               -- ???

 CONSTRAINT pk_award_nomination PRIMARY KEY ( id ),
 CONSTRAINT fk_award_nomination_subject FOREIGN KEY ( subject_id ) REFERENCES award_nomination_subject ( id )
);

-- ???
CREATE TABLE award_nomination_subject
(
 id          integer NOT NULL,
 title       varchar NOT NULL,
 description text,

 CONSTRAINT PK_1 PRIMARY KEY ( id )
);

-- Города
CREATE TABLE city
(
 id         bigint NOT NULL,
 title      varchar(128) NOT NULL,
 country_id char(2) NOT NULL,

 CONSTRAINT pk_city PRIMARY KEY ( id ),
 CONSTRAINT fk_country FOREIGN KEY ( country_id ) REFERENCES country ( id )
);

-- Страны
CREATE TABLE country
(
 id    char(2) NOT NULL,                        -- код страны
 title char(128) NOT NULL,                      -- наименование

 CONSTRAINT pk_country PRIMARY KEY ( id )
);

-- Кинопремии
CREATE TABLE film_award
(
 id          bigint NOT NULL,
 founder     integer NOT NULL,                  -- учредитель кинопремии todo: ссылку на таблицу с организациями
 title       varchar(128) NOT NULL,             -- наименование кинопремии
 found_at    date NOT NULL                      -- дата основания
 ended_at    date NULL                          -- дата ликвидации
 'description' text NULL,

 CONSTRAINT pk_film_award PRIMARY KEY ( id ),
 CONSTRAINT fk_award_founder FOREIGN KEY ( founder ) REFERENCES award_founder ( id )
);

-- Жанры кинолент
CREATE TABLE genre
(
 id    bigint NOT NULL,
 title char(128) NOT NULL,                      -- наименование жанра
 --age_rating integer NULL,

 CONSTRAINT pk_genre PRIMARY KEY ( id )
);

-- Каталог кинолент и сериалов
CREATE TABLE movie
(
 id           bigint NOT NULL,
 title        varchar(128) NOT NULL,            -- наименование
 tags         bigint,                           -- теги
 release_date date,                             -- дата выхода
 budget       numeric,                          -- бюджет фильма
 box_office   numeric,                          -- кассовый сбор
 rating       smallint,                         -- рейтинг
 feedbacks    bigint,                           -- отзывы

 CONSTRAINT pk_movie PRIMARY KEY ( id )
);

-- жанры и относящиеся к ним фильмы
CREATE TABLE movie_genre_m2m
(
 id       bigint NOT NULL,
 genre_id bigint NOT NULL,
 movie_id bigint NOT NULL,

 CONSTRAINT pk_movie_genre_m2m PRIMARY KEY ( id ),
 CONSTRAINT fk_genre FOREIGN KEY ( genre_id ) REFERENCES genre ( id ),
 CONSTRAINT fk_movie FOREIGN KEY ( movie_id ) REFERENCES movie ( id )
);

-- изображения к фильмам (постеры, скриншоты)
CREATE TABLE movie_pic_m2m
(
 id          bigint NOT NULL,
 pic_id      bigint NOT NULL,
 movie_id    bigint NOT NULL,
 description text NOT NULL,

 CONSTRAINT pk_movie_pic_m2m PRIMARY KEY ( id ),
 CONSTRAINT fk_picture FOREIGN KEY ( pic_id ) REFERENCES picture ( id ),
 CONSTRAINT fk_movie FOREIGN KEY ( movie_id ) REFERENCES movie ( id )
);

-- участники съемок
CREATE TABLE movie_staff_m2m
(
 id          bigint NOT NULL,
 part        char NULL,                 -- герой, которого сыграл актер !todo: во внешнюю таблицу - может сыграть больше одной роли в фильме
 position_id varchar NOT NULL,          -- должность
 person_id   bigint NOT NULL,
 movie_id    bigint NOT NULL,

 CONSTRAINT pk_movie_staff_m2m PRIMARY KEY ( id ),
 CONSTRAINT fk_movie_staff_m2m_movie FOREIGN KEY ( movie_id ) REFERENCES movie ( id ),
 CONSTRAINT fk_movie_staff_m2m_person FOREIGN KEY ( person_id ) REFERENCES person ( id ),
 CONSTRAINT fk_movie_staff_m2m_person_position FOREIGN KEY ( position_id ) REFERENCES person_position ( title )
);

-- люди (актеры, режжисеры, ...)
CREATE TABLE person
(
 id         bigint NOT NULL,
 last_name  varchar(128) NOT NULL,
 city_id    bigint,
 first_name varchar(128) NOT NULL,
 mid_name   varchar(128),
 birthday   date,
 education  varchar,

 CONSTRAINT pk_person PRIMARY KEY ( id ),
 CONSTRAINT fk_city FOREIGN KEY ( city_id ) REFERENCES city ( id )
);

-- изображения, относящиеся к актерам, режиссерам (фото, постеры)
CREATE TABLE person_pic_m2m
(
 id         bigint NOT NULL,
 person_id  bigint NOT NULL,
 picture_id bigint NOT NULL,

 CONSTRAINT pk_person_pic_m2m PRIMARY KEY ( id ),
 CONSTRAINT fk_person FOREIGN KEY ( person_id ) REFERENCES person ( id ),
 CONSTRAINT fk_picture FOREIGN KEY ( picture_id ) REFERENCES picture ( id )
);

-- должности, роли (режиссер, актер, продюсер, ...)
CREATE TABLE person_position
(
 title varchar NOT NULL,

 CONSTRAINT pk_person_position PRIMARY KEY ( title )
);

-- изображения
CREATE TABLE picture
(
 id     bigint NOT NULL,
 'path'   varchar NOT NULL,
 width  integer NOT NULL,
 height integer NOT NULL,

 CONSTRAINT pk_picture PRIMARY KEY ( id )
);

-- места проведения награждений
CREATE TABLE place
(
 id       bigint NOT NULL,
 title    varchar(128) NOT NULL,
 city_id  bigint NOT NULL,
 postcode varchar NOT NULL,
 street   varchar,
 build    varchar,
 office   varchar,

 CONSTRAINT pk_place PRIMARY KEY ( id ),
 CONSTRAINT fk_city FOREIGN KEY ( city_id ) REFERENCES city ( id )
);
