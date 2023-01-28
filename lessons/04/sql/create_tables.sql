-- postgres sql

BEGIN;

---
create table country
(
    id   smallserial primary key,
    code char(2)       not null unique,
    title varchar(128) not null,
    constraint country_code_title_unique unique (code, title)
);
comment on table country is 'Каталог стран';
comment on column country.code is 'Код страны';
comment on column country.title is 'Наименование';

---
create table city
(
    id         serial primary key,
    title      varchar(128) not null,
    country_id smallint     not null references country (id) on delete restrict,
    constraint city_country_unique unique (title, country_id)
);
comment on table city is 'Города';

---
create table genre
(
    id    smallserial primary key,
    title char(128) not null unique
);
comment on table genre is 'Каталог жанров кинолент';

---
create table rars
(
    id smallserial primary key,
    title   varchar(5)   not null unique,
    min_age smallint     not null,
    description text     not null,
    country     smallint not null references country on delete restrict,
    constraint rars_age_range_check check ( min_age > 0 and min_age < 19)
);
comment on table rars is 'Возрастная классификация информационной продукции';

---
create table movie
(
    id             serial primary key,
    title          varchar(128) not null,
    title_original varchar(128) not null,
    country        smallint     not null references country,
    "year"         smallint     not null,
    release_date   date,
    budget         numeric,
    boxoffice      numeric,
    rating         smallint,
    duration       integer      not null,
    rars           varchar(5) references rars (title) on update cascade on delete restrict,
    constraint movie_rating_range_check check (rating > 0 and rating < 6),
    constraint movie_duration_pos_check check ( NULL or duration >= 0 ),
    constraint movie_budget_pos_check check ( NULL or budget >= 0 ),
    constraint movie_release_date_check check ( NULL or not (extract( year from release_date) > "year" or extract( year from release_date) < "year"))
);
comment on table movie is 'Каталог кинолент и сериалов';

---
create table movie_genre_m2m
(
    id       serial primary key,
    genre_id smallint   not null references genre on delete cascade,
    movie_id integer    not null references movie on delete cascade,
    constraint movie_genre_unique unique (genre_id, movie_id)
);
comment on table movie_genre_m2m is 'Отношения кинолент к жанрам';

---
create table person
(
    id         serial primary key,
    last_name  varchar(128) not null,
    first_name varchar(128) not null,
    mid_name   varchar(128),
    city_id    integer references city on delete restrict,
    birthday   date,
    education  varchar(128),
    bio        text
);
comment on table person is 'Актеры, режиссеры,...';

---
create table person_position
(
    id smallserial primary key,
    title varchar(128) not null unique
);
comment on table person_position is 'Должности и выполняемые функции участников съемок';

create table movie_staff_m2m
(
    id           serial primary key,
    "character"  varchar(128),           -- исполняемая роль
    is_lead_role boolean  default false, -- главная роль
    position_id  smallint not null references person_position on delete restrict,
    person_id    integer  not null references person on delete restrict,
    movie_id     integer  not null references movie on delete cascade
);
comment on table movie_staff_m2m is 'Участники съемок';

---
create table place
(
    id       smallserial primary key,
    title    varchar(128) not null,
    city_id  integer      not null references city on delete restrict,
    postcode varchar(12)  not null,
    street   varchar(128) not null,
    build    varchar(5)   not null,
    office   varchar(5),
    constraint place_unique_constraint unique (city_id, postcode, street, build, office)
);
comment on table place is 'Места проведения награждений';

---
create table organization
(
    id            smallserial primary key,
    title         varchar(128) not null,
    title_short   varchar(56)  not null,
    place_id      integer      not null references place on delete restrict,
    ceo           integer               references person on delete set null,
    found_at      date,
    close_at      date
);
comment on table organization is 'Каталог организаций юридических лиц';
comment on column organization.title is 'Наименование';
comment on column organization.title_short is 'Краткое наименование';
comment on column organization.place_id is 'Штаб-квартира';
comment on column organization.ceo is 'Шеф';
comment on column organization.found_at is 'Дата основания';

---
create table film_award
(
    id          smallserial  primary key,
    founder     smallint     not null references organization on delete restrict,
    title       varchar(128) not null,
    found_at    date         not null,
    ended_at    date,
    description text
);
comment on table film_award is 'Существующие кино-премии мира';

---
create table award_category
(
    id            smallserial primary key,
    film_award_id smallint     not null references film_award on delete restrict,
    title         varchar(128) not null,
    tier          smallint     not null, -- класс награды
    constraint award_category_tier_pos_check check ( tier > 0 )
);
comment on table award_category is 'Категория награды, относящаяся к кино-премии';

---
create table award_ceremony
(
    id                integer primary key,
    title             varchar(128) not null,
    place_id          smallint     not null references place,
    film_award_id     smallint     not null references film_award,
    start_at          date         not null,
    end_at            date
);
comment on table award_ceremony is 'Проведенные ежегодные церемонии награждения кино-премий';

---
create table award_nomination
(
    id    smallserial primary key,
    title varchar(128) not null unique
);
comment on table award_nomination is 'Наименования существующих номинаций кино-премий';

---
create table award
(
    id             serial primary key,
    award_category smallint not null references award_category on delete restrict,
    ceremony_id    integer  not null references award_ceremony on delete restrict,
    movie_id       integer  not null references movie on delete restrict,
    person_id      integer           references person on delete restrict,
    nomination_id  smallint not null references award_nomination on delete restrict,
    "comment"      text,
    constraint award_unique_constraint unique (ceremony_id, movie_id, nomination_id)
);
comment on table award is 'Врученные награды кино-премий';

---
create table poster_pictures
(
    id        serial primary key,
    file_path varchar(128)  not null,
    width     integer       not null,
    height    integer       not null
);
comment on table poster_pictures is 'Файлы изображений постеров';

---
create table movie_poster_m2m
(
    id          serial primary key,
    movie_id    integer not null references movie on delete cascade,
    poster_id   integer not null references poster_pictures on delete cascade
);
comment on table movie_poster_m2m is 'Постеры к фильмам';

---
create table person_poster_m2m
(
    id        serial primary key,
    person_id integer not null references person on delete cascade,
    poster_id integer not null references poster_pictures on delete cascade
);
comment on table person_poster_m2m is 'Постеры с актерами';

create table tag
(
    id      serial primary key,
    title   varchar(56) not null unique
);
comment on table tag is 'Теги';

---
create table "user"
(
    id       serial primary key,
    username   varchar(64)        not null unique,
    email      varchar(128)       not null unique,
    "password"   varchar(128)     not null, -- password hash
    fio        varchar(128),
    bio        text,
    created_at date default now() not null,
    deleted_at date,
    birthday   date               not null,
    last_logon date,
    constraint user_birthday_check check (birthday < now()),
    constraint user_check_created_less_deleted check ("user".created_at <= "user".deleted_at)
);
comment on table "user" is 'Пользователи кинотеки';

---
create table cinema_online
(
    id    serial primary key,
    title varchar(128) not null unique,
    url   text         not null unique
);
comment on table cinema_online is 'Онлайн кинотеатры';

---
create table cinema_online_movie_presence
(
    id          serial primary key,
    movie_id    integer references movie on delete cascade,
    cinema_id   integer references cinema_online on delete cascade,
    price       numeric not null,
    rating      integer not null,
    discount    smallint default 0 check ( discount >=0 or discount <= 100 ), -- скидка для студентов
    view_count  integer,
    last_update date,
    constraint movie_cinema_rating_check check (rating > 0 and rating < 6),
    constraint cinema_online_movie_presence_unique unique (movie_id, cinema_id)
);
comment on table cinema_online_movie_presence is 'Наличие фильмов в онлайн-кинотеатрах';

---
create table user_movie_orders
(
    id               serial primary key,
    cinema_order_id  uuid               not null,
    movie_id         integer references movie on delete restrict,
    user_id          integer references "user" on delete restrict,
    online_cinema_id integer references cinema_online on delete restrict,
    price            numeric            not null check ( price >= 0 ),
    "date"           date default now() not null,
    constraint user_movie_orders_m2m_pk2 unique (user_id, movie_id, online_cinema_id)
);
comment on table user_movie_orders is 'Заказы просмотров фильмов пользователями фильмов в онлайн-кинотеатрах';
comment on column user_movie_orders.cinema_order_id is 'Идентификационный номер заказа в кинотеатре';

---
create table publications_category
(
    id    serial primary key,
    title varchar(24) not null unique
);
comment on table publications_category is 'Категории публикаций (новости, обзор, анонс, ...)';

--- Публикации, обзоры, критика пользователей (студентов и преподавателей)
create table publications
(
    id          bigserial primary key,
    title       varchar(256)       not null,
    "text"      text               not null,
    author      integer references "user",
    "category"  integer references publications_category on delete restrict,
    create_date date default now() not null,
    change_date date               not null
)
    tablespace fast_ts; -- fast table spase
comment on table publications is 'Публикации о кинематографе по категориям';

---
create table tag_m2m
(
    tag_id         integer references tag on delete cascade,
    movie_id       integer references movie on delete cascade,
    publication_id integer references publications on delete cascade,
    constraint tag_movie_unique unique (movie_id, tag_id),
    constraint publication_movie_check
        check (not (movie_id is null and publication_id is null) or
               not (movie_id is not null and publication_id is not null))
)
    tablespace fast_ts; -- fast table spase
comment on table tag_m2m is 'Теги фильмов и публикаций';

---
create table users_rating
(
    id             serial primary key,
    rating         smallint     not null,
    user_id        integer      not null    references "user" on delete cascade,
    movie_id       integer                  references movie on delete cascade,
    publication_id bigint                   references publications on delete cascade,
    "date"         timestamp    not null default now(),
    constraint users_rating_unique_pk2 unique (movie_id, publication_id, user_id),
    constraint user_rating_check_range_1_5 check (rating > 0 and rating < 6),
    constraint user_comments_rating_check -- рейтинг только к фильму или публикации
        check (not (movie_id is null and publication_id is null) or
               not (movie_id is not null and publication_id is not null))
)
    tablespace fast_ts; -- fast table spase
comment on table users_rating is 'Пользовательский рейтинг';

---
create table comments
(
    id             bigserial primary key,
    user_id        integer references "user" on delete set null,
    "comment"        text             not null,
    parent_id      integer references comments on delete restrict,
    movie_id       integer references movie on delete cascade,
    publication_id integer references publications on delete cascade,
    create_date    date default now() not null,
    change_date    date,
    constraint comments_on_movie_and_publication_check -- комментарий только к фильму или публикации
        check (not (movie_id is null and publication_id is null) or
               not (movie_id is not null and publication_id is not null))
)
    tablespace fast_ts;
comment on table comments is 'Комментарии пользователей';

-- INDEXES

-- одна кинопремия в год
create unique index award_ceremony_unique_idx on award_ceremony (film_award_id, extract(year from start_at));
create index movie_title_idx on movie (title);
create index movie_title_original_idx on movie (title_original);
create index movie_rating_idx on movie (rating);
create index user_fio_idx on "user" (fio);
create index person_name_idx on person (last_name, first_name);
create index award_ceremony_title_idx on award_ceremony (title);
create index publications_title_idx on publications (title) tablespace fast_ts;
create index publications_text_idx on publications (text) tablespace fast_ts; -- todo: add FTS
create index publications_create_date_idx on publications (create_date) tablespace fast_ts;

COMMIT;