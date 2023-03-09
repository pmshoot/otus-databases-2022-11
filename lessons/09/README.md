# DML: агрегация и сортировка, CTE, аналитические функции

## Посчитать кол-во очков по всем игрокам за текущий год и за предыдущий.

Создаем и заполняем данными таблицу `Statistics`:

```postgresql
 player_name | player_id | year_game | points
-------------+-----------+-----------+--------
 Mike        |         1 |      2018 |  18.00
 Jack        |         2 |      2018 |  14.00
 Jackie      |         3 |      2018 |  30.00
 Jet         |         4 |      2018 |  30.00
 Luke        |         1 |      2019 |  16.00
 Mike        |         2 |      2019 |  14.00
 Jack        |         3 |      2019 |  15.00
 Jackie      |         4 |      2019 |  28.00
 Jet         |         5 |      2019 |  25.00
 Luke        |         1 |      2020 |  19.00
 Mike        |         2 |      2020 |  17.00
 Jack        |         3 |      2020 |  18.00
 Jackie      |         4 |      2020 |  29.00
 Jet         |         5 |      2020 |  27.00
(14 строк)
```
---
### Суммы очков с группировкой и сортировкой по годам:

- простая выборка с группировкой и сортировкой

```sql
SELECT
  year_game,
  sum(points) points
  FROM statistic
GROUP BY year_game
ORDER BY year_game
```

```postgresql
 year_game | points
-----------+--------
      2018 |  92.00
      2019 |  98.00
      2020 | 110.00
(3 строки)
```

- выборка через CTE и оконную функцию:

```sql
WITH sum_points AS (
	SELECT
	year_game ,
	sum(points) OVER (PARTITION BY year_game) AS points
	FROM statistic
)
select year_game , points
FROM sum_points
GROUP BY year_game, points
ORDER BY year_game;
```

```postgresql
 year_game | points
-----------+--------
      2018 |  92.00
      2019 |  98.00
      2020 | 110.00
(3 строки)
```

### Кол-во очков по всем игрокам за текущий год и за предыдущий + прирост

- простой запрос через оконную функцию

```sql
SELECT
  s.player_name,
  s.year_game,
  lag(s.points) OVER w AS prev_year,
  s.points AS curr_year,
  s.points - lag(s.points) OVER w AS growth
FROM statistic s
WINDOW w AS (PARTITION BY player_name ORDER by year_game);
```

- запрос через CTE и оконную функцию

```sql
WITH d AS (
	SELECT
		s.player_name,
		s.year_game,
		lag(s.points) OVER w AS prev_year,
		s.points AS curr_year
	FROM statistic s
	WINDOW w AS (PARTITION BY player_name ORDER by year_game)
)
SELECT
	player_name,
	year_game,
	prev_year,
	curr_year,
	curr_year - prev_year AS growth
FROM d
```

```
WindowAgg  (cost=25.34..32.09 rows=300 width=300)
  ->  Sort  (cost=25.34..26.09 rows=300 width=236)
        Sort Key: player_name, year_game
        ->  Seq Scan on statistic s  (cost=0.00..13.00 rows=300 width=236)


Subquery Scan on d  (cost=25.34..35.09 rows=300 width=300)
  ->  WindowAgg  (cost=25.34..31.34 rows=300 width=268)
        ->  Sort  (cost=25.34..26.09 rows=300 width=236)
              Sort Key: s.player_name, s.year_game
              ->  Seq Scan on statistic s  (cost=0.00..13.00 rows=300 width=236)

```


Результат выборки:

```postgresql
 player_name | year_game | prev_year | curr_year | growth
-------------+-----------+-----------+-----------+--------
 Jack        |      2018 |           |     14.00 |
 Jack        |      2019 |     14.00 |     15.00 |   1.00
 Jack        |      2020 |     15.00 |     18.00 |   3.00
 Jackie      |      2018 |           |     30.00 |
 Jackie      |      2019 |     30.00 |     28.00 |  -2.00
 Jackie      |      2020 |     28.00 |     29.00 |   1.00
 Jet         |      2018 |           |     30.00 |
 Jet         |      2019 |     30.00 |     25.00 |  -5.00
 Jet         |      2020 |     25.00 |     27.00 |   2.00
 Luke        |      2019 |           |     16.00 |
 Luke        |      2020 |     16.00 |     19.00 |   3.00
 Mike        |      2018 |           |     18.00 |
 Mike        |      2019 |     18.00 |     14.00 |  -4.00
 Mike        |      2020 |     14.00 |     17.00 |   3.00
(14 строк)
```