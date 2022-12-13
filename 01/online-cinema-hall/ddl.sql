drop database if exists kinoteka;

create database kinoteka owner portaladmin;

CREATE TABLE award
(
 id             bigint NOT NULL,
 title           NOT NULL,
 award_category integer NOT NULL,
 ceremony_id    bigint NOT NULL,
 person_id      bigint,
 movie_id       bigint NOT NULL,
 nomitation_id  bigint NOT NULL,

 CONSTRAINT PK_1 PRIMARY KEY ( id ),
 CONSTRAINT FK_14 FOREIGN KEY ( nomitation_id ) REFERENCES award_nomination ( id ),
 CONSTRAINT FK_16 FOREIGN KEY ( movie_id ) REFERENCES movie ( id ),
 CONSTRAINT FK_17 FOREIGN KEY ( person_id ) REFERENCES person ( id ),
 CONSTRAINT FK_18 FOREIGN KEY ( ceremony_id ) REFERENCES award_ceremony ( id ),
 CONSTRAINT FK_20 FOREIGN KEY ( award_category ) REFERENCES award_category ( id )
);

CREATE TABLE award_category
(
 id            integer NOT NULL,
 title          NOT NULL,
 film_award_id bigint NOT NULL,
 tier          integer NOT NULL,

 CONSTRAINT PK_1 PRIMARY KEY ( id ),
 CONSTRAINT FK_19 FOREIGN KEY ( film_award_id ) REFERENCES film_award ( id )
);

CREATE TABLE award_ceremony
(
 id                bigint NOT NULL,
 title             char(128) NOT NULL,
 place_id          bigint NOT NULL,
 award_category_id bigint NOT NULL,
 start_at          date NOT NULL,
 end_at            date NOT NULL,

 CONSTRAINT PK_1 PRIMARY KEY ( id ),
 CONSTRAINT FK_11_1 FOREIGN KEY ( award_category_id ) REFERENCES film_award ( id ),
 CONSTRAINT FK_12 FOREIGN KEY ( place_id ) REFERENCES place ( id )
);

CREATE TABLE award_founder
(
 id      integer NOT NULL,
 title   char(128) NOT NULL,
 country char(2) NOT NULL,

 CONSTRAINT PK_1 PRIMARY KEY ( id ),
 CONSTRAINT FK_4 FOREIGN KEY ( country ) REFERENCES countries ( id )
);

CREATE TABLE award_nomination
(
 id         bigint NOT NULL,
 title      varchar NOT NULL,
 subject_id integer NOT NULL,

 CONSTRAINT PK_1 PRIMARY KEY ( id ),
 CONSTRAINT FK_15 FOREIGN KEY ( subject_id ) REFERENCES award_nomination_subject ( id )
);

CREATE TABLE award_nomination_subject
(
 id          integer NOT NULL,
 title       varchar NOT NULL,
 description text,

 CONSTRAINT PK_1 PRIMARY KEY ( id )
);

CREATE TABLE city
(
 id         bigint NOT NULL,
 title      varchar(128) NOT NULL,
 country_id char(2) NOT NULL,

 CONSTRAINT PK_1 PRIMARY KEY ( id ),
 CONSTRAINT FK_10_1 FOREIGN KEY ( country_id ) REFERENCES countries ( id )
);

CREATE TABLE countries
(
 id    char(2) NOT NULL,
 title char(128) NOT NULL,

 CONSTRAINT PK_1 PRIMARY KEY ( id )
);

CREATE TABLE film_award
(
 id          bigint NOT NULL,
 founder     integer NOT NULL,
 title       varchar(128) NOT NULL,
 description text NOT NULL,

 CONSTRAINT PK_2 PRIMARY KEY ( id ),
 CONSTRAINT FK_3 FOREIGN KEY ( founder ) REFERENCES award_founder ( id )
);

CREATE TABLE genre
(
 id    bigint NOT NULL,
 title char(128) NOT NULL,

 CONSTRAINT PK_1 PRIMARY KEY ( id )
);

CREATE TABLE movie
(
 id           bigint NOT NULL,
 title        varchar(128) NOT NULL,
 tags         bigint,
 release_date date,
 awards       bigint,
 budget       numeric,
 box_office   numeric,
 rating       smallint,
 feedbacks    bigint,

 CONSTRAINT PK_1 PRIMARY KEY ( id )
);

CREATE TABLE movie_genre_m2m
(
 id       bigint NOT NULL,
 genre_id bigint NOT NULL,
 movie_id bigint NOT NULL,

 CONSTRAINT PK_1 PRIMARY KEY ( id ),
 CONSTRAINT FK_10 FOREIGN KEY ( genre_id ) REFERENCES genre ( id ),
 CONSTRAINT FK_11 FOREIGN KEY ( movie_id ) REFERENCES movie ( id )
);

CREATE TABLE movie_pic_m2m
(
 id          bigint NOT NULL,
 pic_id      bigint NOT NULL,
 movie_id    bigint NOT NULL,
 description text NOT NULL,

 CONSTRAINT PK_1 PRIMARY KEY ( id ),
 CONSTRAINT FK_22 FOREIGN KEY ( pic_id ) REFERENCES pictures ( id ),
 CONSTRAINT FK_23 FOREIGN KEY ( movie_id ) REFERENCES movie ( id )
);

CREATE TABLE movie_staff_m2m
(
 id          bigint NOT NULL,
 part        ,
 position_id varchar NOT NULL,
 person_id   bigint NOT NULL,
 movie_id    bigint NOT NULL,

 CONSTRAINT PK_1 PRIMARY KEY ( id ),
 CONSTRAINT FK_16_1 FOREIGN KEY ( movie_id ) REFERENCES movie ( id ),
 CONSTRAINT FK_17_1 FOREIGN KEY ( person_id ) REFERENCES person ( id ),
 CONSTRAINT FK_18_1 FOREIGN KEY ( position_id ) REFERENCES person_position ( title )
);

CREATE TABLE person
(
 id         bigint NOT NULL,
 last_name  varchar(128) NOT NULL,
 city_id    bigint,
 first_name varchar(128) NOT NULL,
 mid_name   varchar(128),
 birthday   date,
 pics       bigint,
 awards     bigint,
 languages  varchar,
 education  varchar,

 CONSTRAINT PK_1 PRIMARY KEY ( id ),
 CONSTRAINT FK_19_1 FOREIGN KEY ( city_id ) REFERENCES city ( id )
);

CREATE TABLE person_pic_m2m
(
 id        bigint NOT NULL,
 person_id bigint NOT NULL,
 id_1      bigint NOT NULL,

 CONSTRAINT PK_1 PRIMARY KEY ( id ),
 CONSTRAINT FK_21 FOREIGN KEY ( person_id ) REFERENCES pictures ( id ),
 CONSTRAINT FK_21_1 FOREIGN KEY ( id_1 ) REFERENCES person ( id )
);

CREATE TABLE person_position
(
 title varchar NOT NULL,

 CONSTRAINT PK_1 PRIMARY KEY ( title )
);

CREATE TABLE pictures
(
 id     bigint NOT NULL,
 path   varchar NOT NULL,
 width  integer NOT NULL,
 height integer NOT NULL,

 CONSTRAINT PK_1 PRIMARY KEY ( id )
);

CREATE TABLE place
(
 id       bigint NOT NULL,
 title    varchar(128) NOT NULL,
 city_id  bigint NOT NULL,
 postcode varchar NOT NULL,
 street   varchar,
 build    varchar,
 office   varchar,

 CONSTRAINT PK_1 PRIMARY KEY ( id ),
 CONSTRAINT FK_13 FOREIGN KEY ( city_id ) REFERENCES city ( id )
);

