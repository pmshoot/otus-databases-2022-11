# Физическая и логическая репликации

## Физическая репликация

1. На ВМ Ubuntu 22.04 установлен postgresql-server-14.

```shell
postgres@osboxes:~$ pg_lsclusters 
Ver Cluster Port Status          Owner    Data directory                Log file
14  main    5432 online          postgres /var/lib/postgresql/14/main   /var/log/postgresql/postgresql-14-main.log
postgres@osboxes:~$ 
```

Создадим пользователя для репликации на первом кластере:

```postgresql
CREATE USER repluser REPLICATION ENCRYPTED PASSWORD 'replica';
CREATE ROLE
```

Убедимся, что в файле pg_hba.conf есть правила авторизации для репликации:

```shell
# Allow replication connections from localhost, by a user with the
# replication privilege.
local   replication     all                                     peer
host    replication     repluser        127.0.0.1/32            scram-sha-256
host    replication     repluser        10.0.0.0/8              scram-sha-256
host    replication     all             ::1/128                 scram-sha-256
```


2. Cоздадим второй кластер БД:

```shell
postgres@osboxes:~$ pg_createcluster 14 slave2
Creating new PostgreSQL cluster 14/slave2 ...
/usr/lib/postgresql/14/bin/initdb -D /var/lib/postgresql/14/slave2 --auth-local peer --auth-host scram-sha-256 --no-instructions
...
Ver Cluster Port Status Owner    Data directory                Log file
14  slave1  5433 down   postgres /var/lib/postgresql/14/slave1 /var/log/postgresql/postgresql-14-slave1.log
```

В вайл pg_hba.conf второго кластера пропишем настройки аналогичные первому кластеру.

Удалим содержимое каталога данных второго кластера:

```shell
osboxes@osboxes:~$ sudo rm -rf /var/lib/postgresql/14/slave1/
osboxes@osboxes:~$ ls -l /var/lib/postgresql/14/slave1/
ls: cannot access '/var/lib/postgresql/14/slave1/': No such file or directory
```

И создадим копию первого кластера во второй кластер с ключом -R для активации режима репликации (read-only) и 
ключами `-C -S repl_slot-slave1` для создания и использования слота тепликации:

```shell
osboxes@osboxes:~$ sudo -u postgres pg_basebackup -h 127.0.0.1 -p 5432 -R -C -S repl_slot-slave1 -D /var/lib/postgresql/14/slave1
osboxes@osboxes:~$ sudo -u postgres ls -l /var/lib/postgresql/14/slave1/
total 256
-rw------- 1 postgres postgres    225 Mar 25 10:52 backup_label
-rw------- 1 postgres postgres 179983 Mar 25 10:52 backup_manifest
drwx------ 6 postgres postgres   4096 Mar 25 10:52 base
drwx------ 2 postgres postgres   4096 Mar 25 10:52 global
drwx------ 2 postgres postgres   4096 Mar 25 10:52 pg_commit_ts
drwx------ 2 postgres postgres   4096 Mar 25 10:52 pg_dynshmem
drwx------ 4 postgres postgres   4096 Mar 25 10:52 pg_logical
drwx------ 4 postgres postgres   4096 Mar 25 10:52 pg_multixact
drwx------ 2 postgres postgres   4096 Mar 25 10:52 pg_notify
drwx------ 2 postgres postgres   4096 Mar 25 10:52 pg_replslot
drwx------ 2 postgres postgres   4096 Mar 25 10:52 pg_serial
drwx------ 2 postgres postgres   4096 Mar 25 10:52 pg_snapshots
drwx------ 2 postgres postgres   4096 Mar 25 10:52 pg_stat
drwx------ 2 postgres postgres   4096 Mar 25 10:52 pg_stat_tmp
drwx------ 2 postgres postgres   4096 Mar 25 10:52 pg_subtrans
drwx------ 2 postgres postgres   4096 Mar 25 10:52 pg_tblspc
drwx------ 2 postgres postgres   4096 Mar 25 10:52 pg_twophase
-rw------- 1 postgres postgres      3 Mar 25 10:52 PG_VERSION
drwx------ 3 postgres postgres   4096 Mar 25 10:52 pg_wal
drwx------ 2 postgres postgres   4096 Mar 25 10:52 pg_xact
-rw------- 1 postgres postgres    326 Mar 25 10:52 postgresql.auto.conf
-rw------- 1 postgres postgres      0 Mar 25 10:52 standby.signal
```

В параметрах postgres сервера резервного кластера установим задержку применения WAL-файлов в 5 минут:

```shell
recovery_min_apply_delay = 5min         # minimum delay for applying changes during recovery
```

Запустим второй кластер:

```shell
osboxes@osboxes:~$ sudo -u postgres pg_ctlcluster 14 slave1 start
osboxes@osboxes:~$ pg_lsclusters 
Ver Cluster Port Status Owner    Data directory                Log file
14  main    5432 online postgres /var/lib/postgresql/14/main   /var/log/postgresql/postgresql-14-main.log
14  slave1  5433 online postgres /var/lib/postgresql/14/slave1 /var/log/postgresql/postgresql-14-slave1.log
```

3. Проверка репликации

Мастер-сервер:

- Статус слота репликации:

```postgresql
student=# select * from pg_replication_slots \gx
-[ RECORD 1 ]-------+-----------------
slot_name           | repl_slot_slave1
plugin              | 
slot_type           | physical
datoid              | 
database            | 
temporary           | f
active              | t
active_pid          | 1860
xmin                | 
catalog_xmin        | 
restart_lsn         | 0/9000788
confirmed_flush_lsn | 
wal_status          | reserved
safe_wal_size       | 
two_phase           | f
```

- статус репликации

```postgresql
student=# select * from pg_stat_replication \gx
-[ RECORD 1 ]----+------------------------------
pid              | 1860
usesysid         | 10
usename          | postgres
application_name | 14/slave1
client_addr      | 127.0.0.1
client_hostname  | 
client_port      | 34234
backend_start    | 2023-03-25 11:37:21.451755+00
backend_xmin     | 
state            | streaming
sent_lsn         | 0/9000788
write_lsn        | 0/9000788
flush_lsn        | 0/9000788
replay_lsn       | 0/9000788
write_lag        | 
flush_lag        | 
replay_lag       | 
sync_priority    | 0
sync_state       | async
reply_time       | 2023-03-25 12:00:48.856498+00
```

Резервный сервер:

- статус репликации

```postgresql
student=# select * from pg_stat_wal_receiver \gx
-[ RECORD 1 ]---------
pid                   | 1859
status                | streaming
receive_start_lsn     | 0/9000000
receive_start_tli     | 1
written_lsn           | 0/9000788
flushed_lsn           | 0/9000788
received_tli          | 1
last_msg_send_time    | 2023-03-25 12:00:58.852421+00
last_msg_receipt_time | 2023-03-25 12:00:58.852696+00
latest_end_lsn        | 0/9000788
latest_end_time       | 2023-03-25 11:43:27.083553+00
slot_name             | repl_slot_slave1
sender_host           | 127.0.0.1
sender_port           | 5432
conninfo              | user=postgres password=******** channel_binding=prefer dbname=replication host=127.0.0.1 port=5432 fallback_application_name=14/slave1 sslmode=prefer sslcompression=0 sslsni=1 ssl_min_protocol_version=TLSv1.2 gssencmode=prefer krbsrvname=postgres target_session_attrs=any
```

Проверим процесс репликации при изменении данных на местер-сервере:

Добавим данные в таблицу `student`:

```postgresql
student=# insert into student values (11, '-123123-');
INSERT 0 1
student=# select * from student ;
 id |    md5     
----+------------
  1 | d193bcd062
  2 | 2ef3a6266d
  3 | b119dad663
  4 | 3121e748a0
  5 | f0841d2905
  6 | 762128727e
  7 | 49d2da1a55
  8 | 2f417e46db
  9 | f681676f68
 10 | 17ed154a69
 11 | -123123-  
(11 строк)
```

В это же время на резервном сервере:

```postgresql
student=# select * from student;
 id |    md5     
----+------------
  1 | d193bcd062
  2 | 2ef3a6266d
  3 | b119dad663
  4 | 3121e748a0
  5 | f0841d2905
  6 | 762128727e
  7 | 49d2da1a55
  8 | 2f417e46db
  9 | f681676f68
 10 | 17ed154a69
(11 строк)
```


**Мастер**:

```postgresql
student=# select pg_current_wal_lsn();
 pg_current_wal_lsn 
--------------------
 0/9000A78
```

**Резервный**:

```postgresql
student=# select pg_last_wal_receive_lsn();
 pg_last_wal_receive_lsn 
-------------------------
 0/9000A78

student=# select pg_last_wal_replay_lsn();
 pg_last_wal_replay_lsn 
------------------------
 0/9000A18

```

Данные на резервном сервере, согласно установкам задержки в настройках, получены с мастера, но еще не применены.

...через 5 минут...

**Мастер**

```postgresql
student=# select pg_current_wal_lsn();
 pg_current_wal_lsn 
--------------------
 0/9000B60
 ```

**Резервный**

```postgresql
student=# select pg_last_wal_receive_lsn();
 pg_last_wal_receive_lsn 
-------------------------
 0/9000B60
 ```

```postgresql
student=# select pg_last_wal_replay_lsn();
 pg_last_wal_replay_lsn 
------------------------
 0/9000B60
(1 строка)
```

```postgresql
student=# select * from student;
 id |    md5     
----+------------
  1 | d193bcd062
  2 | 2ef3a6266d
  3 | b119dad663
  4 | 3121e748a0
  5 | f0841d2905
  6 | 762128727e
  7 | 49d2da1a55
  8 | 2f417e46db
  9 | f681676f68
 10 | 17ed154a69
 11 | -123123-  
(11 строк)
```

Данные применились и LSN выровнялся.

## Логическая репликация

**Мастер-сервер**

На мастер-сервере установим параметр `wal_level = logical` и перезагрузим кластер
```postgresql
postgres=# show wal_level;
 wal_level 
-----------
 logical
(1 строка)
```

Создадим еще одну БД с 2-мя таблицами и произвольными данными:

```postgresql
student=# create database test;
CREATE DATABASE

student=# \c test
psql (15.2, сервер 14.7 (Ubuntu 14.7-0ubuntu0.22.04.1))
SSL-соединение (протокол: TLSv1.3, шифр: TLS_AES_256_GCM_SHA384, сжатие: выкл.)
Вы подключены к базе данных "test" как пользователь "postgres".

test=# CREATE EXTENSION pgcrypto;
CREATE EXTENSION

test=# create table data as select
generate_series(1,100) as id,
random()::int as num,
digest(random()::text, 'sha256')::text as label;

test=# create table data2 as select
generate_series(1,10) as id,
ceiling(random() * 1000)::int as num,
digest(random()::text, 'sha256')::text as label;
```

Cоздадим публикацию на таблицу `test.data2`:
```postgresql
test=# create publication test_data2_pub for table data2;
CREATE PUBLICATION

test=# \dRp+
                                Публикация test_data2_pub
 Владелец | Все таблицы | Добавления | Изменения | Удаления | Опустошения | Через корень 
----------+-------------+------------+-----------+----------+-------------+--------------
 postgres | f           | t          | t         | t        | t           | f
Таблицы:
    "public.data2"

```

Выдадим права доступа на чтение пользователю `repluser` на таблицу `data2`:

```sql
test=# grant select ON data2 TO repluser;
GRANT
```

Создадим еще один кластер БД:

```shell
postgres@osboxes:/home/osboxes$ pg_createcluster 14 test
Creating new PostgreSQL cluster 14/test ...
/usr/lib/postgresql/14/bin/initdb -D /var/lib/postgresql/14/test --auth-local peer --auth-host scram-sha-256 --no-instructions
...
Ver Cluster Port Status Owner    Data directory              Log file
14  test    5434 down   postgres /var/lib/postgresql/14/test /var/log/postgresql/postgresql-14-test.log
```

Создадим БД `test` и таблицу `data2` идентично мастер-серверу и подписку:

```postgresql
postgres=# create subscription test_data2_sub connection 'host=127.0.0.1 port=5432 user=repluser password=replica dbname=test' PUBLICATION test_data2_pub with (copy_data=true);
NOTICE:  created replication slot "test_data2_sub" on publisher
CREATE SUBSCRIPTION

postgres=# \dRs
                 List of subscriptions
      Name      |  Owner   | Enabled |   Publication    
----------------+----------+---------+------------------
 test_data2_sub | postgres | t       | {test_data2_pub}
(1 row)

```

Проверим статус репликации:

**Мастер (публикация)**
```postgresql
-[ RECORD 2 ]----+------------------------------
pid              | 2347
usesysid         | 16384
usename          | repluser
application_name | test_data2_sub
client_addr      | 127.0.0.1
client_hostname  | 
client_port      | 36330
backend_start    | 2023-03-25 12:51:44.988889+00
backend_xmin     | 
state            | streaming
sent_lsn         | 0/90905D8
write_lsn        | 0/90905D8
flush_lsn        | 0/90905D8
replay_lsn       | 0/90905D8
write_lag        | 
flush_lag        | 
replay_lag       | 
sync_priority    | 0
sync_state       | async
reply_time       | 2023-03-25 13:06:33.339588+00
```

**Реплика (подписка)**

```postgresql
postgres=# select * from pg_stat_subscription \gx
-[ RECORD 1 ]---------+------------------------------
subid                 | 16390
subname               | test_data2_sub
pid                   | 2346
relid                 | 
received_lsn          | 0/90905D8
last_msg_send_time    | 2023-03-25 13:05:13.233212+00
last_msg_receipt_time | 2023-03-25 13:05:13.233533+00
latest_end_lsn        | 0/90905D8
latest_end_time       | 2023-03-25 13:05:13.233212+00
```

Выборка на репликации:

```sql
postgres=# select * from data2 ;
 id | num |                               label                                
----+-----+--------------------------------------------------------------------
  1 | 245 | \xfb0b1fa87596fb1c3f2a0d4e80efab622a20b3ab51d3fb7ee9d61e1a97b7698d
  2 |  73 | \x8329fe214963e78f2ddd32dcc082c0f2d523e4ce12ba35f282a4e4e1df1bcda1
  3 | 798 | \x63ad9c821f00caea2496a490aa2570d964f6ce8d3c9fe421efc5e1f002b10703
  4 | 292 | \x7974effee6d51c328a4e77402d90beca0563aef470d1d9e6b8bc104515255e58
  5 | 174 | \xde30dc55bbfa707965bd5141e37da644bb003183c0ec3bb04fb01b55a35d6318
  6 | 740 | \xe800b021b787786535f64fbbce2fb62cb781e647df0042dc0a028fc17742dc37
  7 | 445 | \x7ebf803d9de198f041445d9e4f73c6e98b13fca25caf758d54f1fb686772a5f9
  8 | 533 | \x128b5599cab9cc2d23359b7cd88b4c00e578976eb5da3517ae370480adbc220c
  9 | 138 | \x1f404960c920f7824a078af525baa99a39e49f0b1a6285e9c8a461d4849b77a6
 10 | 746 | \x4fcb89515baf9b05e12311f81fcad89ff98b49c43c29ebdfff1a1bbde896aa87
(10 rows)
```

Добавим запись на мастер-сервере в таблицу `data2`:

```sql
test=# insert into data2 values
(11, 123, 'jgflksjldfogkj');
```

Проверим состояние репликации на реплике:

```sql
postgres=# select * from data2 ;
 id | num |                               label                                
----+-----+--------------------------------------------------------------------
  1 | 245 | \xfb0b1fa87596fb1c3f2a0d4e80efab622a20b3ab51d3fb7ee9d61e1a97b7698d
  2 |  73 | \x8329fe214963e78f2ddd32dcc082c0f2d523e4ce12ba35f282a4e4e1df1bcda1
  3 | 798 | \x63ad9c821f00caea2496a490aa2570d964f6ce8d3c9fe421efc5e1f002b10703
  4 | 292 | \x7974effee6d51c328a4e77402d90beca0563aef470d1d9e6b8bc104515255e58
  5 | 174 | \xde30dc55bbfa707965bd5141e37da644bb003183c0ec3bb04fb01b55a35d6318
  6 | 740 | \xe800b021b787786535f64fbbce2fb62cb781e647df0042dc0a028fc17742dc37
  7 | 445 | \x7ebf803d9de198f041445d9e4f73c6e98b13fca25caf758d54f1fb686772a5f9
  8 | 533 | \x128b5599cab9cc2d23359b7cd88b4c00e578976eb5da3517ae370480adbc220c
  9 | 138 | \x1f404960c920f7824a078af525baa99a39e49f0b1a6285e9c8a461d4849b77a6
 10 | 746 | \x4fcb89515baf9b05e12311f81fcad89ff98b49c43c29ebdfff1a1bbde896aa87
 11 | 123 | jgflksjldfogkj
(11 rows)
```
