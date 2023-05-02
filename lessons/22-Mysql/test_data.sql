INSERT INTO country (code, title) VALUES 
('RU', 'Россия'),
('US', 'США'),
('CH', 'Китай');
SELECT * FROM country;

INSERT INTO rars (title, description, min_age, country) VALUES
('R', 'лицам до 17 лет обязательно присутствие взрослого', 10, 2),
('12+', 'Возрастное ограничение 12 лет', 12, 1)
;
SELECT * FROM rars;


INSERT INTO movie (title, title_original,  country, created_year, duration, rars, extra) VALUES
('Джон Уик 4', 'John Wick: Chapter 4', 2, 2023, 169, 1, '{"world_premier": "13 марта 2023", "russia_premier": "23 марта 2023", "slogan": "Baba Yaga"}'),
('Вызов', NULL, 1, 2023, 164, 2, '{"world_premier": "20 апреля 2023", "russia_premier": "20 апреля 2023, «Централ Партнершип»"}'),
('В погоне за счастьем', 'The Pursuit of Happyness', 2, 2006, 117, 2, '{"world_premier": "15 декабря 2006", "russia_premier": "22 марта 2007, «Каскад фильм»", "DVD-release": "7 апреля 2007, «Columbia/Sony»", "BR-release": "19 июля 2007, «Columbia/Sony»"}')
;
SELECT * FROM movie;
