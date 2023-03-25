BEGIN;

-- 
TRUNCATE publications_category cascade;
INSERT INTO publications_category (id, title) values
(1, 'Обзор'),
(2, 'Эссе'),
(3, 'Отзыв'),
(4, 'Анонс'),
(5, 'Рецензия'),
(6, 'Статья');
SELECT setval ('publications_category_id_seq', 6, true);

TRUNCATE "user" CASCADE;
INSERT INTO "user" (id, username, email, "password", fio, birthday) values
(1, 'asaka', 'asaka@mail.com', 'jpowjpgoijf', 'Ася Филатова', '01-01-1996'),
(2, 'amuri', 'amuri@mail.com', 'mgf;dl5hgfh', 'Александр Муразов', '16-12-1966'),
(3, 'seva', 'seva@mail.com', 'mgf;dl5hgfh', 'Сергей Иванов', '16-12-1966'),
(4, 'sid', 'sid@mail.com', 'mgf;dl5hgfh', 'Иван Сидоров', '16-12-1966');
SELECT setval('user_id_seq', 4, true);


TRUNCATE publications CASCADE;
INSERT INTO publications (id, title, "text", author, category, change_date) VALUES
(1, 'Чебурашка и все, все, все...', 'ojpopojpgojportjhpowrjhporw', 4, 1, now()),
(2, 'Кто подставил чебурашку', 'ojpopojpgojportjhpowrjhporw', 2, 2, now()),
(3, 'Белый пояс', 'ojpopojpgojportjhpowrjhporw', 1, 4, now()),
(4, 'Фильм Чебурашка побил все рекорды по сборам', 'ojpopojpgojportjhpowrjhporw', 1, 6, now()),
(5, 'Кто подставил кролика Роджера', 'mgkl;wlrkt;okrt;okt;hok',  2, 5, now()),
(6, 'Кто подставил чебурашку', 'ojpopojpgojportjhpowrjhporw', 3, 1, now())
RETURNING *
;
SELECT setval('publications_id_seq', 6, true);


--

TRUNCATE "country" cascade;
INSERT INTO country (id, code, title) values 
(1, 'RU', 'Россия'),
(2, 'FR', 'Франция'),
(3, 'US', 'США')
;
SELECT setval('country_id_seq', 3, true);

TRUNCATE "rars" cascade;
INSERT INTO rars (id, title, min_age, description, country) values 
(1, '16+', 16, 'С 16 +', 1),
(2, '18+', 18, 'С 18 +', 1),
(3, 'PG16+', 16, 'PG13+', 3)
;

TRUNCATE genre cascade ;
INSERT INTO genre (id, title) values 
(1, 'Триллер'),
(2, 'Фантастика'),
(3, 'Драма'),
(4, 'Приключения'),
(5, 'Комедия'),
(6, 'Ужасы')
;
SELECT setval('genre_id_seq', 6, true);


TRUNCATE movie cascade ;
INSERT INTO movie (id, title, title_original, country, "year", rating,duration, rars) values 
(1, 'Западня', NULL, 1, 2003, 2,123, '16+'),
(2, 'Зеленая миля', 'The Green Mile', 3, 1999, 5, 189, '16+'),
(3, 'Пила', 'Saw', 3, 2003, 2, 9, '16+'),
(4, 'Интерстеллар', 'Interstellar16', 3, 2014, 5, 169, '16+'),
(5, 'Дрожь', 'Tremor', 2, 1992, 3, 165, '16+')
;
SELECT setval('country_id_seq', 4, true);


INSERT INTO movie_genre_m2m (id, movie_id, genre_id) values 
(1, 1, 3),
(2, 1, 1),
(3, 2, 3),
(4, 4, 2),
(5, 3, 1),
(6, 3, 6),
(7, 5, 1)
;
SELECT setval('movie_genre_m2m_id_seq', 6, true);

TRUNCATE "comments" CASCADE;
INSERT INTO "comments" (id, user_id, "comment", parent_id, movie_id) values 
(1, 2, 'gjkfldk hgjfkksj gjkflkj hjfgk', NULL, 4),
(2, 4, 'aaaaaa )))', NULL, 3),
(3, 2, 'жесть )))', 2, 3),
(4, 1, 'сойдет ..', NULL, 1)
;
SELECT setval('comments_id_seq', 4, true);

---
TRUNCATE person cascade ;
INSERT INTO person (id, last_name, first_name) values 
(1, 'Aston', 'Persey'),
(2, 'Красильников', 'Алексей'),
(3, 'Зуев', 'Андрей'),
(4, 'Ashley', 'Anna'),
(5, 'Золотарева', 'Валентина'),
(6, 'Паулайтис', 'Анжелика'),
(7, 'Кувалдин', 'Серж'),
(8, 'Кинчев', 'Армен'),
(9, 'Breadley', 'Saymon')
;
SELECT setval('person_id_seq', 9, true);

TRUNCATE person_position cascade ;
INSERT INTO person_position (id, title) VALUES
(1, 'Актер'),
(2, 'Режиссер'),
(3, 'Продюсер'),
(4, 'Звукооператор'),
(5, 'Сценарист')
;
SELECT setval('person_position_id_seq', 5, true);

INSERT INTO movie_staff_m2m (id, movie_id, person_id, position_id) values 
(1, 4, 1, 4),
(2, 1, 3, 1),
(3, 1, 8, 4),
(4, 1, 7, 3),
(5, 1, 5, 1),
(6, 3, 9, 1),
(7, 3, 1, 1),
(8, 3, 2, 3)
;
SELECT setval('movie_staff_m2m_id_seq', 8, true);


INSERT INTO users_rating (rating, user_id, movie_id) values 
(5, 1, 2),
(3, 2, 2),
(4, 3, 2),
(5, 4, 2),
(1,2,3),
(4,4,3),
(5,1,4),
(5,2,4),
(3,3,4),
(4,4,4),
(1, 1, 5),
(3, 3, 5),
(5, 4, 5)


COMMIT;