# Индексы

Для работы будет использована учебно-тренировочная БД _"Авиаперевозки"_ от PostgresPro.

1. Поиск билетов определенного клиента по фамилии, имени.

Определим план выполнения запроса на поиск всех билетов, заказанных на пассажира 'IVAN VLASOV':

```postgresql
EXPLAIN
SELECT ticket_no,
       passenger_id,
       passenger_name
FROM tickets
WHERE passenger_name = 'IVAN VLASOV'
```

```
Gather  (cost=1000.00..121213.24 rows=264 width=42)
  Workers Planned: 2
  ->  Parallel Seq Scan on tickets  (cost=0.00..120186.84 rows=110 width=42)
        Filter: (passenger_name = 'IVAN VLASOV'::text)
```

Поиск данных происходит путем перебора по таблице (`Parallel Seq Scan on tickets`), т.к. поле `passenger_name` не проиндексировано. Стоимость 
запроса по расчетам планировщика обойдется в 1000.00..121213.24 единиц.
Создадим `Btree` индекс:

```postgresql
CREATE INDEX tickets_passenger_name_btree_idx ON tickets (passenger_name);
```


После создания индекса прогноз планировщика гораздо привлекательнее - 0.43..296.54 единиц. Продолжительность 
создания - 34с. Поиск производится по индексу `Index Scan using tickets_passenger_name_btree_idx`:

```
Index Scan using tickets_passenger_name_btree_idx on tickets  (cost=0.43..296.54 rows=264 width=42)
  Index Cond: (passenger_name = 'IVAN VLASOV'::text)
```

При размере таблицы `tickets` в 819Mb и увеличении скорости поиска в разы, размер индекса в 21Mb выглядит очень 
выгодным.

```
  Схема   |   Имя   |   Тип   | Владелец |  Хранение  | Метод доступа | Размер | Описание 
----------+---------+---------+----------+------------+---------------+--------+----------
 bookings | tickets | таблица | dba      | постоянное | heap          | 819 MB | Tickets
```

```
  Схема   |               Имя                |  Тип   | Владелец | Таблица |  Хранение  | Метод доступа | Размер | Описание 
----------+----------------------------------+--------+----------+---------+------------+---------------+--------+----------
 bookings | tickets_passenger_name_btree_idx | индекс | dba      | tickets | постоянное | btree         | 21 MB  | 
```

Но для поиска по индексу требуется указывать полное значения искомого поля - `IVAN VLASOV`. Если нам потребуется 
найти билеты заказанные на имя `IVAN`, то данный индекс работать уже не будет:

```postgresql
EXPLAIN
SELECT ticket_no,
       passenger_id,
       passenger_name
FROM tickets
WHERE passenger_name like 'IVAN%'
```

Оптимизатор не использует индекс, а снова перебирает все записи:

```
Gather  (cost=1000.00..123920.24 rows=27334 width=42)
  Workers Planned: 2
  ->  Parallel Seq Scan on tickets  (cost=0.00..120186.84 rows=11389 width=42)
        Filter: (passenger_name ~~ 'IVAN%'::text)
```

2. Для поиска по словам из строк лучше использовать полнотекстовый индекс (поиск уникальных пассажиров с фамилией 
   Власов) :

```postgresql
CREATE INDEX tickets_passenger_name_gin_idx
   ON bookings.tickets USING gin (TO_TSVECTOR('english', passenger_name));

EXPLAIN
SELECT passenger_name
FROM tickets
WHERE TO_TSVECTOR('english', passenger_name) @@ TO_TSQUERY('VLASOV')
GROUP BY passenger_name
```

```
Finalize HashAggregate  (cost=20267.79..20346.55 rows=7876 width=16)
  Group Key: passenger_name
  ->  Gather  (cost=18946.62..20237.07 rows=12290 width=16)
        Workers Planned: 2
        ->  Partial HashAggregate  (cost=17946.62..18008.07 rows=6145 width=16)
              Group Key: passenger_name
              ->  Parallel Bitmap Heap Scan on tickets  (cost=123.36..17931.26 rows=6145 width=16)
                    Recheck Cond: (to_tsvector('english'::regconfig, passenger_name) @@ to_tsquery('VLASOV'::text))"
                    ->  Bitmap Index Scan on tickets_passenger_name_gin_idx  (cost=0.00..119.67 rows=14749 width=0)
                          Index Cond: (to_tsvector('english'::regconfig, passenger_name) @@ to_tsquery('VLASOV'::text))"

```

В начале поиска оптимизатором был задействован индекс `Bitmap Index Scan on tickets_passenger_name_gin_idx`, затем 
поиск соответствия в куче (таблице), затем группировка значений.

3. _В случаях, когда поиск чаще всего происходит по каким-то определенным значениям поля, на больших данных имеет 
   смысл в некоторых случаях сделать частичный индекс (по-условию)_:

Обновлено:

[Согласно документации по Postgres](https://postgrespro.ru/docs/postgrespro/15/indexes-partial), при поиске 
распространенного значения индекс не используется и при больших данных хранить эти строки в индексе не имеет смысла.

Например, в таблице/поле `ticket_flights.fare_conditions` распространенным значением является `Economy`:

```postgresql
SELECT fare_conditions,
       COUNT(fare_conditions)
FROM ticket_flights
GROUP BY fare_conditions;

+---------------+-------+
|fare_conditions|count  |
+---------------+-------+
|Business       |859656 |
|Comfort        |139965 |
|Economy        |7392231|
+---------------+-------+
```

Создание индекса по всем строкам заняло ~ 50с и его размер составил 56Мб. При выборке по классу `Economy` 
оптимизатор запроса индекс не использовал:

```postgresql
EXPLAIN
SELECT ticket_no,
       flight_id
FROM ticket_flights
WHERE fare_conditions = 'Economy';
```

```
   Seq Scan on ticket_flights  (cost=0.00..174831.15 rows=7372242 width=18)
     Filter: ((fare_conditions)::text = 'Economy'::text)
```

Поэтому создадим частичный индекс, исключающий данные `Economy`. На создание ушло всего 3с и его 
размер составил 6888Кб:

```postgresql
DROP INDEX IF EXISTS ticket_flights_fare_idx;
CREATE INDEX ticket_flights_fare_idx ON ticket_flights (fare_conditions)
    WHERE fare_conditions != 'Economy';
```

Теперь при выборке данных по фильтру `Business` и `Comfort` оптимизатор использует созданный индекс, а по значению 
`Economy` идет перебор строк:

```postgresql
EXPLAIN
SELECT
    ticket_no,
    flight_id
FROM ticket_flights
WHERE fare_conditions = 'Business'
-- WHERE fare_conditions = 'Comfort'
-- WHERE fare_conditions = 'Economy'
;
```

```
Index Scan using ticket_flights_fare_idx on ticket_flights  (cost=0.42..40009.65 rows=888977 width=22)
  Index Cond: ((fare_conditions)::text = 'Business'::text)                                            

Index Scan using ticket_flights_fare_idx on ticket_flights  (cost=0.42..20561.26 rows=130633 width=22)
  Index Cond: ((fare_conditions)::text = 'Comfort'::text)

Seq Scan on ticket_flights  (cost=0.00..174831.15 rows=7372242 width=22)
  Filter: ((fare_conditions)::text = 'Economy'::text)
```

4. Создание индекса пна поле с функцией

```postgresql
CREATE INDEX tickets_passenger_name_fun_lower_idx ON tickets (LOWER(passenger_name));

EXPLAIN
SELECT ticket_no,
       passenger_id,
       passenger_name
FROM tickets
WHERE LOWER(passenger_name) = 'ivan vlasov'
;
;
```

```
Bitmap Heap Scan on tickets  (cost=130.13..15009.74 rows=14749 width=42)
  Recheck Cond: (lower(passenger_name) = 'ivan vlasov'::text)
  ->  Bitmap Index Scan on tickets_passenger_name_fun_lower_idx  (cost=0.00..126.45 rows=14749 width=0)
        Index Cond: (lower(passenger_name) = 'ivan vlasov'::text)
```

5. Создадим индекс по двум полям. Предварительно создадим два поля `passenger_sname` и `passenger_fname` путем 
   разделения значения поля `passenger_name`.

```postgresql
DROP INDEX IF EXISTS tickets_passenger_sfn_idx;
CREATE INDEX tickets_passenger_sfn_idx ON tickets (passenger_sname, passenger_fname);
```

Теперь при выборке с предикатом по новым двум полям будет задействован один индекс:

```postgresql
EXPLAIN
SELECT ticket_no,
       passenger_id,
       passenger_name
FROM tickets
WHERE
  passenger_sname = 'VLASOV'
  and passenger_fname = 'EGOR';

-------------------------------
Index Scan using tickets_passenger_sfn_idx on tickets  (cost=0.43..36.25 rows=31 width=42)
  Index Cond: ((passenger_sname = 'VLASOV'::text) AND (passenger_fname = 'EGOR'::text))
```

```postgresql
EXPLAIN
SELECT ticket_no,
       passenger_id,
       passenger_name
FROM tickets
WHERE
  passenger_sname = 'VLASOV'
  or passenger_fname = 'EGOR';

------------------------------
Bitmap Heap Scan on tickets  (cost=25212.90..44019.47 rows=19045 width=42)
  Recheck Cond: ((passenger_sname = 'VLASOV'::text) OR (passenger_fname = 'EGOR'::text))
  ->  BitmapOr  (cost=25212.90..25212.90 rows=19076 width=0)
        ->  Bitmap Index Scan on tickets_passenger_sfn_idx  (cost=0.00..88.12 rows=10226 width=0)
              Index Cond: (passenger_sname = 'VLASOV'::text)
        ->  Bitmap Index Scan on tickets_passenger_sfn_idx  (cost=0.00..25115.26 rows=8850 width=0)
              Index Cond: (passenger_fname = 'EGOR'::text)

```