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
    rars           integer
        references movie_rars (title)
            on update cascade on delete restrict
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

create table movie_review_m2m
(
    id         serial
        primary key,
    text       text               not null,
    created_at date default now() not null,
    movie_id   integer
        references movie
            on delete cascade,
    person_id  integer
        references person
            on delete cascade,
    unique (movie_id, person_id)
);

comment on table movie_review_m2m is 'Рецензии на фильм';

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


create table tag
(
    title varchar
        primary key
);

create table tag_movie_m2m
(
    movie_id  integer
        constraint tag_movie_m2m_movie_id_fk
            references movie
            on update cascade on delete cascade,
    tag_title integer
        constraint tag_movie_m2m_tag_title_fk
            references tag
            on update cascade on delete cascade,
    constraint tag_movie_m2m_pk
        unique (movie_id, tag_title)
);

comment on table tag_movie_m2m is 'Теги для фильмов';

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

create table feedback
(
    id         serial
        constraint feedback_pk
            primary key,
    text       text               not null,
    movie_id   integer
        constraint feedback_movie_id_fk
            references movie
            on delete cascade,
    "user"     varchar
        constraint feedback_user_username_fk
            references "user"
            on update cascade on delete cascade,
    created_at date default now() not null
);

comment on table feedback is 'Отзывы';

create table movie_rating_m2m
(
    id       bigserial
        constraint movie_rating_m2m_pk
            primary key,
    rating   smallint not null,
    movie_id integer
        constraint movie_rating_m2m_movie_id_fk
            references movie
            on delete cascade,
    user_id  integer
        constraint movie_rating_m2m_user_id_fk
            references "user"
            on delete cascade,
    constraint movie_rating_check_range_1_5
        check (rating > 0 and rating < 6)
);

comment on table movie_rating_m2m is 'Пользовательский рэйтинг фильмов';

create table cinema_online
(
    id    serial
        constraint online_cinema_pk
            primary key,
    title varchar(128) not null,
    url   varchar(256) not null
);

comment on table cinema_online is 'Онлайн кинотеатры';

create table cinema_online_movie_presence_m2m
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

comment on table cinema_online_movie_presence_m2m is 'Наличие фильмов в онлайн-кинотеатрах';

comment on column cinema_online_movie_presence_m2m.view_count is 'Количество просмотров';

create table user_movie_orders_m2m
(
    id               bigserial
        constraint user_movie_orders_m2m_pk
            primary key,
    cinema_order_id  uuid               not null,
    movie_id         integer
        constraint user_movie_orders_m2m_movie_id_fk
            references movie
            on update cascade on delete cascade,
    user_id          integer
        constraint user_movie_orders_m2m_user_username_fk
            references "user"
            on update cascade on delete cascade,
    online_cinema_id integer
        constraint user_movie_orders_m2m_cinema_online_id_fk
            references cinema_online
            on delete restrict,
    price            numeric            not null,
    date             date default now() not null
);

comment on table user_movie_orders_m2m is 'Заказы просмотров фильмов пользователями фильмов в онлайн-кинотеатрах';

comment on column user_movie_orders_m2m.cinema_order_id is 'Идентификационный номер заказа в кинотеатре';

create table user_movie_comments_m2m
(
    id          bigserial
        constraint user_movie_comments_m2m_pk
            primary key,
    user_id     integer
        constraint user_movie_comments_m2m_user_username_fk
            references "user"
            on delete cascade,
    movie_id    integer
        constraint user_movie_comments_m2m_movie_id_fk
            references movie
            on delete cascade,
    comment     varchar(1024)      not null,
    create_date date default now() not null,
    parent_id   integer
        constraint user_movie_comments_m2m_user_movie_comments_m2m_id_fk
            references user_movie_comments_m2m
);

comment on table user_movie_comments_m2m is 'Комментарии пользователей к фильму';