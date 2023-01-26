-- postgres sql
BEGIN;
create table award_nomination
(
    id    smallserial
        primary key,
    title varchar not null
);

comment on table award_nomination is 'Номинации кинопремий';

create table country
(
    id    char(2)
        primary key,
    title char(128) not null
);

comment on table country is 'Каталог стран';

comment on column country.id is 'Код страны';

comment on column country.title is 'Наименование';

create table city
(
    id         serial
        primary key,
    title      varchar(128) not null,
    country_id char(2)      not null
        references country
);

comment on table city is 'Города';

create table genre
(
    id    smallserial
        primary key,
    title char(128) not null
        unique
);

comment on table genre is 'Жанры кинолент';

create table movie_rars
(
    title   varchar(3) not null
        constraint movie_rars_pk
            primary key,
    min_age smallint   not null,
    comment varchar    not null
);

comment on table movie_rars is 'Возрастная классификация';

create table movie
(
    id             serial
        primary key,
    title          varchar(128) not null,
    title_original varchar(128) not null,
    country        char         not null
        references country (id),
    year           smallint     not null,
    release_date   date,
    budget         numeric      not null,
    boxoffice      numeric,
    rating         smallint     not null,
    duration       integer      not null,
    rars           varchar(3)
        references movie_rars (title)
            on update cascade on delete restrict,
    constraint movie_rating_check
        check (rating > 0 and rating < 6)
);

comment on table movie is 'Каталог кинолент и сериалов';

create table movie_genre_m2m
(
    id       serial
        primary key,
    genre_id bigint not null
        references genre,
    movie_id bigint not null
        references movie
);

create table person
(
    id         serial
        primary key,
    last_name  varchar(128) not null,
    city_id    integer
        references city,
    first_name varchar(128) not null,
    mid_name   varchar(128),
    birthday   date,
    education  varchar
);

comment on table person is 'Актеры, режиссеры,...';


create table person_position
(
    title varchar
        primary key
);

comment on table person_position is 'Занимаемые должности';

create table movie_staff_m2m
(
    id           serial
        primary key,
    character    char,
    is_lead_role boolean default FALSE,
    position_id  varchar not null
        references person_position,
    person_id    bigint  not null
        references person,
    movie_id     bigint  not null
        references movie
);
comment on table poster is 'Участники съемок';

create table place
(
    id       smallserial
        primary key,
    title    varchar(128) not null,
    city_id  integer      not null
        references city,
    postcode varchar      not null,
    street   varchar,
    build    varchar,
    office   varchar
);

comment on table place is 'Места проведения награждений';

create table organization
(
    id            smallserial
        constraint organization_pk
            primary key,
    title         varchar not null,
    title_short   varchar not null,
    place_id      integer
        constraint organization_place_id_fk
            references place,
    ceo           integer
        constraint organization_person_id_fk
            references person,
    found_at      date,
    liquidated_at date
);

comment on table organization is 'Каталог организаций юридических лиц';

comment on column organization.title is 'Наименование';

comment on column organization.title_short is 'Краткое наименование';

comment on column organization.place_id is 'Главный офис';

comment on column organization.ceo is 'Директор';

comment on column organization.found_at is 'Дата основания';

create table film_award
(
    id          smallserial
        primary key,
    founder     integer      not null
        references organization,
    title       varchar(128) not null,
    found_at    date         not null,
    ended_at    date,
    description text
);

comment on table film_award is 'Учредитель кинопремии';

create table award_category
(
    id            smallserial
        primary key,
    title         char(128) not null,
    film_award_id bigint    not null
        references film_award,
    tier          integer   not null
);

comment on table award_category is 'Категория награды, относящаяся к кинопремии';

create table award_ceremony
(
    id                integer
        primary key,
    title             char(128) not null,
    place_id          smallint  not null
        references place,
    award_category_id integer   not null
        references film_award,
    start_at          date      not null,
    end_at            date      not null
);

comment on table award_ceremony is 'Церемонии награждения';

create table award
(
    id             serial
        primary key,
    award_category integer not null
        references award_category,
    ceremony_id    integer not null
        references award_ceremony,
    movie_id       integer not null
        references movie,
    person_id      integer
        references person,
    nomitation_id  integer not null
        references award_nomination,
    constraint award_unique_constraint
        unique (ceremony_id, movie_id, nomitation_id)
);

comment on table award is 'Полученные награды';

create table poster
(
    id        serial
        primary key,
    file_path varchar,
    width     integer not null,
    height    integer not null
);

comment on table poster is 'Изображения';

create table movie_poster_m2m
(
    id          serial
        primary key,
    pic_id      integer not null
        references poster,
    movie_id    integer not null
        references movie,
    description text    not null
);
comment on table poster is 'Постеры к фильмам';

create table person_poster_m2m
(
    person_id integer not null
        references person,
    poster_id integer not null
        constraint person_poster_m2m_id_fk
            references poster,
    id        serial
        primary key
);
comment on table poster is 'Постеры с актерами';

create table tag
(
    title varchar
        primary key
);
comment on table poster is 'Теги';

create table "user"
(
    username   varchar(64)        not null
        constraint user_pk
            primary key,
    email      varchar(128)       not null
        constraint user_email
            unique,
    fio        varchar(128),
    created_at date default now() not null,
    deleted_at date,
    password   varchar            not null,
    birthday   date               not null,
    last_logon date,
    constraint user_birthday_check
        check (birthday < now()),
    constraint user_check_created_less_deleted
        check ("user".created_at <= "user".deleted_at)
);

comment on table "user" is 'Пользователи кинотеки';

comment on column "user".username is 'Имя пользователя';

create table cinema_online
(
    id    serial
        constraint online_cinema_pk
            primary key,
    title varchar(128) not null,
    url   varchar(256) not null
);

comment on table cinema_online is 'Онлайн кинотеатры';

create table cinema_online_movie_presence
(
    id          bigserial
        constraint movie_cinema_presence_m2m_pk
            primary key,
    movie_id    integer
        constraint movie_cinema_presence_m2m_movie_id_fk
            references movie
            on update cascade on delete cascade,
    cinema_id   integer
        constraint movie_cinema_presence_m2m_online_cinema_id_fk
            references cinema_online
            on update cascade on delete cascade,
    price       numeric not null,
    rating      integer,
    view_count  integer,
    last_update date,
    constraint movie_cinema_rating_check
        check (rating > 0 and rating < 6)
);

comment on table cinema_online_movie_presence is 'Наличие фильмов в онлайн-кинотеатрах';

comment on column cinema_online_movie_presence.view_count is 'Количество просмотров';

create table user_movie_orders
(
    id               bigserial
        constraint user_movie_orders_m2m_pk
            primary key,
    cinema_order_id  uuid               not null,
    movie_id         integer
        constraint user_movie_orders_m2m_movie_id_fk
            references movie
            on update cascade on delete cascade,
    user_id          varchar(64)
        constraint user_movie_orders_m2m_user_username_fk
            references "user"
            on update cascade on delete cascade,
    online_cinema_id integer
        constraint user_movie_orders_m2m_cinema_online_id_fk
            references cinema_online
            on delete restrict,
    price            numeric            not null,
    date             date default now() not null,
    constraint user_movie_orders_m2m_pk2
        unique (user_id, movie_id, online_cinema_id)
);

comment on table user_movie_orders is 'Заказы просмотров фильмов пользователями фильмов в онлайн-кинотеатрах';

comment on column user_movie_orders.cinema_order_id is 'Идентификационный номер заказа в кинотеатре';

create table publications_category
(
    id    serial
        constraint publications_category_pk
            primary key,
    title varchar(24) not null
);

comment on table publications_category is 'Категории публикаций (новости, обзор, анонс, ...)';

create table publications
(
    id          bigserial
        constraint publications_pk
            primary key,
    title       varchar(256)       not null,
    text        text               not null,
    author      varchar(64)
        constraint publications_user_username_fk
            references "user",
    category    integer
        constraint publications_publications_category_id_fk
            references publications_category (id),
    create_date date default now() not null,
    change_date date               not null
) tablespace fast_ts;

comment on table publications is 'Публикации о кинематографе по категориям';

-- create able tag_m2m at tablespace fast_ts
create table tag_m2m
(
    movie_id       integer
        constraint tag_m2m_movie_id_fk
            references movie
            on update cascade on delete cascade,
    tag_title      varchar
        constraint tag_m2m_tag_title_fk
            references tag
            on update cascade on delete cascade,
    publication_id integer
        constraint tag_m2m_publications_id_fk
            references publications,
    constraint tag_m2m_pk
        unique (movie_id, tag_title),
    constraint publication_movie_check
        check (not (movie_id is null and publication_id is null) or
               not (movie_id is not null and publication_id is not null))
)  tablespace fast_ts;

comment on table tag_m2m is 'Теги для фильмов и публикаций';

create table users_rating
(
    id             bigserial
        constraint users_rating_pk
            primary key,
    rating         smallint  not null,
    movie_id       integer
        constraint users_rating_movie_id_fk
            references movie
            on delete cascade,
    user_id        varchar(64)   not null
        constraint user_rating_user_id_fk
            references "user"
            on delete cascade,
    publication_id integer
        constraint users_rating_publications_id_fk
            references publications,
    date           timestamp not null,
    constraint users_rating_pk2
        unique (movie_id, publication_id, user_id),
    constraint user_comments_rating_check
        check ((movie_id is null and publication_id is not null) or
               (movie_id is not null and publication_id is null) or
               not (movie_id is null and publication_id is null) or
               not (movie_id is not null and publication_id is not null)),
    constraint user_rating_check_range_1_5
        check (rating > 0 and rating < 6)
) tablespace fast_ts;

comment on table users_rating is 'Пользовательский рэйтинг';

create table comments
(
    id             bigserial          not null
        constraint comments_pk
            primary key,
    user_id        varchar(64)        not null
        constraint comments_user_username_fk
            references "user"
            on delete cascade,
    comment        text               not null,
    create_date    date default now() not null,
    parent_id      integer
        constraint comments_comments_id_fk
            references comments,
    movie_id       integer
        constraint comments_movie_id_fk
            references movie
            on delete cascade
        constraint comments_movie_id_fk2
            references movie,
    publication_id integer
        constraint comments_publications_id_fk
            references publications,
    change_date    date,
    constraint coments_on_movie_and_publication_check
        check ((movie_id is null and publication_id is not null) or
               (movie_id is not null and publication_id is null) or
               not (movie_id is null and publication_id is null) or
               not (movie_id is not null and publication_id is not null))
) tablespace fast_ts;

comment on table comments is 'Комментарии пользователей';

COMMIT;