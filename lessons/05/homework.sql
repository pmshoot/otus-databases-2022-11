-- postgres sql
-- 01 + Напишите запрос по своей базе с регулярным выражением, добавьте пояснение, что вы хотите найти

-- выборка публикаций по фильму Чебурашка в категориях Эссе, Обзор, Отзыв
-- и фамилии авторов Иванов, Сидоров, Абельшвицер; сначала новые
SELECT p.title,
       u.fio,
       pc.title,
       p.create_date,
       p."text"
FROM publications p
         JOIN publications_category pc ON pc.id = p.category
         JOIN "user" u ON u.id = p.author
WHERE pc.title IN ('Эссе', 'Обзор', 'Отзыв')
  AND p.title ILIKE '%чебураш%'
   AND (u.fio ILIKE '%иванов%'
     OR u.fio ILIKE '%сидоров%'
     OR u.fio ILIKE '%абельшвицер%')
ORDER BY p.create_date DESC
;

-- 02. Напишите запрос по своей базе с использованием LEFT JOIN и INNER JOIN, как порядок соединений в FROM влияет на результат? Почему?

-- выборка фильмов жанра триллер с комментариями или без c рейтингом больше 1
-- comment: таблица movie_genre_m2m mg должна стоять перед таблицей genre g, иначе будет ошибка, так как mg используется для соединения
-- c g, а она еще не объявлена;
-- если выбирать по полю комментариев и соединять left join, в выборку не попадут фильмы без комментариев
SELECT m.title,
       c.comment
FROM movie m
         INNER JOIN movie_genre_m2m mg ON m.id = mg.movie_id
         INNER JOIN genre g ON g.id = mg.genre_id
         left JOIN comments c ON c.movie_id = m.id
WHERE g.title = 'Триллер'
  AND m.rating > 1
ORDER BY m.title
;

-- + 03. Напишите запрос на добавление данных с выводом информации о добавленных строках

INSERT INTO publications (title, "text", author, category, change_date) VALUES
('Чебурашка и все, все, все...', 'ojpopojpgojportjhpowrjhporw', 4, 1, now()),
('Кто подставил чебурашку', 'ojpopojpgojportjhpowrjhporw', 2, 2, now()),
('Белый пояс', 'ojpopojpgojportjhpowrjhporw', 1, 4, now()),
('Фильм Чебурашка побил все рекорды по сборам', 'ojpopojpgojportjhpowrjhporw', 1, 6, now()),
('Кто подставил кролика Роджера', 'mgkl;wlrkt;okrt;okt;hok',  2, 5, now()),
('Кто придумал чебурашку', 'ojpopojpgojportjhpowrjhporw', 3, 1, now())
RETURNING *
;

-- 04. Напишите запрос с обновлением данные используя UPDATE FROM
BEGIN;
WITH avg_rating AS (
	SELECT movie_id, round(avg(rating)) "rating"
		FROM users_rating
		GROUP BY movie_id
	)
UPDATE movie m 
	SET rating = ar.rating
		FROM avg_rating AS ar
		WHERE ar.movie_id = m.id 
	
RETURNING *
;
ROLLBACK;



-- 05. Напишите запрос для удаления данных с оператором DELETE используя join с другой таблицей с помощью using
-- Удаляем "заброшенных" persons, которые не имеют отношений ни с одной из таблиц
--BEGIN;	-- для теста
WITH empty_persons AS (
	SELECT 
	p.id person_id,
	m.id m_id,
	pp.id p_id,
	a.id a_id,
	o.id o_id 
	FROM person p 
		-- movie relation
		LEFT JOIN movie_staff_m2m msmm ON msmm.person_id = p.id
		LEFT JOIN movie m ON msmm.movie_id = m.id
		-- poster relation
		LEFT JOIN person_poster_m2m ppmm ON ppmm.poster_id = p.id
		LEFT JOIN poster_pictures pp ON ppmm.poster_id = pp.id
		-- award relation
		LEFT JOIN award a ON a.person_id = p.id	
		-- organisation relation
		LEFT JOIN organization o ON o.ceo = p.id
		)
		
DELETE FROM person p
	USING empty_persons ep
	
WHERE 
	p.id = ep.person_id 
	AND ep.m_id IS NULL -- не участвует в фильмах
	AND ep.p_id IS NULL -- не имеет постеров
	AND ep.a_id IS NULL -- не участвовал в награждениях
	AND ep.o_id IS NULL -- не принадлежит к организациям
	
RETURNING *
;
--rollback;	-- для теста


-- + 06. * Приведите пример использования утилиты COPY
-- 1 вариант - считывание данных со стандартного ввода, с разделителем по-умолчанию - tabalation
COPY publications (id, title, "text", author, category, change_date) FROM STDIN;
1	'Чебурашка и все, все, все...'	'ojpopojpgojportjhpowrjhporw'	4	1	'01-01-2000'
2	'Кто подставил чебурашку'	'ojpopojpgojportjhpowrjhporw'	2	2	'01-01-2000'
3	'Белый пояс'	'ojpopojpgojportjhpowrjhporw'	1	4	'01-01-2000'
4	'Фильм Чебурашка побил все рекорды по сборам'	'ojpopojpgojportjhpowrjhporw'	1	6	'01-01-2000'
5	'Кто подставил кролика Роджера'	'mgkl;wlrkt;okrt;okt;hok'	2	5	'01-01-2000'
6	'Кто придумал чебурашку'	'ojpopojpgojportjhpowrjhporw'	3	1	'01-01-2000'
\.

SELECT setval('publications_id_seq', 6, true);

-- 2 вариант - считывание данных со стандартного ввода, с разделителем '|'
COPY publications (id, title, "text", author, category, change_date) FROM STDIN WITH (DELIMITER '|');
1|'Чебурашка и все, все, все...'|'ojpopojpgojportjhpowrjhporw'|4|1|'01-01-2000'
2|'Кто подставил чебурашку'|'ojpopojpgojportjhpowrjhporw'|2|2|'01-01-2000'
3|'Белый пояс'|'ojpopojpgojportjhpowrjhporw'|1|4|'01-01-2000'
4|'Фильм Чебурашка побил все рекорды по сборам'|'ojpopojpgojportjhpowrjhporw'|1|6|'01-01-2000'
5|'Кто подставил кролика Роджера'|'mgkl;wlrkt;okrt;okt;hok'|2|5|'01-01-2000'
6|'Кто придумал чебурашку'|'ojpopojpgojportjhpowrjhporw'|3|1|'01-01-2000'
\.

SELECT setval('publications_id_seq', 6, true);

-- 3 вариант - считывание данных из текстового файла, с разделителем по-умолчанию - tabulation
COPY publications (title, "text", author, category, change_date) FROM '/full/path/to/file/on/server/file.txt';
-- содержимое файла file.txt:
--Чебурашка и все, все, все...	ojpopojpgojportjhpowrjhporw	4	1	2023-02-13
--Кто подставил чебурашку	ojpopojpgojportjhpowrjhporw	2	2	2023-02-13
--Белый пояс	ojpopojpgojportjhpowrjhporw	1	4	2023-02-13
--Фильм Чебурашка побил все рекорды по сборам	ojpopojpgojportjhpowrjhporw	1	6	2023-02-13
--Кто подставил кролика Роджера	mgkl;wlrkt;okrt;okt;hok	2	5	2023-02-13
--Кто подставил чебурашку	ojpopojpgojportjhpowrjhporw	3	1	2023-02-13


-- 4 вариант - считывание данных из csv файла, с разделителем ';'
COPY publications (title, "text", author, category, change_date) FROM '/full/path/to/file/on/server/file.csv' WITH (FORMAT csv, DELIMITER '|');
-- содержимое файла file.csv:
--Чебурашка и все, все, все...|ojpopojpgojportjhpowrjhporw|4|1|2023-02-13
--Кто подставил чебурашку|ojpopojpgojportjhpowrjhporw|2|2|2023-02-13
--Белый пояс|ojpopojpgojportjhpowrjhporw|1|4|2023-02-13
--Фильм Чебурашка побил все рекорды по сборам|ojpopojpgojportjhpowrjhporw|1|6|2023-02-13
--Кто подставил кролика Роджера|mgkl;wlrkt;okrt;okt;hok|2|5|2023-02-13
--Кто подставил чебурашку|ojpopojpgojportjhpowrjhporw|3|1|2023-02-13

-- 5 вариант - запись данных данных в стандартный вывод в формате csv, с разделителем ';'
COPY publications (title, "text", author, category, change_date) TO STDOUT WITH (FORMAT csv, DELIMITER ';');



