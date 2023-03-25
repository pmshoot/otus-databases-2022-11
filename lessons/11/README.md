# Создание базы данных MySQL в докере

### `init.sql` 

```sql
CREATE database IF NOT EXISTS student;
USE student;
CREATE table test(
	id int NOT NULL AUTO_INCREMENT, 
	t text,
	PRIMARY KEY (id)
);
insert into test values
(1, 'qweqweqwe'),
(2, '123453451345'),
(3, 'prepared data');
```

### `custom.conf`

```ini
[mysqld]
default-authentication-plugin=mysql_native_password
init_connect=‘SET collation_connection = utf8_unicode_ci’
character-set-server = utf8
collation-server = utf8_unicode_ci
innodb_buffer_pool_size = 4G
innodb_log_file_size = 1G
max_connections = 250
skip_name_resolve
```

### Старт контейнера

```shell
otus-mysql-docker git:(master) ✗ docker-compose up otusdb               
[+] Running 2/0
 ✔ Volume "otus-mysql-docker_data"       Created                                                                                                                                     0.0s 
 ✔ Container otus-mysql-docker-otusdb-1  Created                                                                                                                                     0.1s 
Attaching to otus-mysql-docker-otusdb-1
otus-mysql-docker-otusdb-1  | Initializing database
otus-mysql-docker-otusdb-1  |  100 200 300 400 500 600 700 800 900 1000
...

➜  otus-mysql-docker git:(master) ✗ docker ps
CONTAINER ID   IMAGE          COMMAND                  CREATED          STATUS          PORTS                                                  NAMES
1ae4767b58de   mysql:8.0.15   "docker-entrypoint.s…"   12 minutes ago   Up 12 seconds   33060/tcp, 0.0.0.0:3309->3306/tcp, :::3309->3306/tcp   otus-mysql-docker-otusdb-1

➜  otus-mysql-docker git:(master) ✗ docker exec -it 1ae4767b58de bash
root@1ae4767b58de:/# 

root@1ae4767b58de:/# mysql -u root -p12345
mysql: [Warning] Using a password on the command line interface can be insecure.
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 10
Server version: 8.0.15 MySQL Community Server - GPL

Copyright (c) 2000, 2019, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| student            |
| sys                |
+--------------------+
5 rows in set (0.00 sec)

mysql> use student
Database changed

mysql> show tables;
+-------------------+
| Tables_in_student |
+-------------------+
| test              |
+-------------------+
1 row in set (0.00 sec)

mysql> select * from test;
+----+---------------+
| id | t             |
+----+---------------+
|  1 | qweqweqwe     |
|  2 | 123453451345  |
|  3 | prepared data |
+----+---------------+
3 rows in set (0.00 sec)

```

### `sysbench`

**CPU**

```shell
➜  sysbench git:(master) ✗ sysbench /usr/share/sysbench/oltp_read_write.lua --mysql-host=127.0.0.1 --mysql-port=3309 --mysql-user=root --mysql-password='12345' --mysql-db=student --db-driver=mysql --tables=3 --table-size=10000000 --report-interval=20 --threads=64 --time=300 run
sysbench 1.0.20 (using system LuaJIT 2.0.5)

Running the test with following options:
Number of threads: 64
Report intermediate results every 20 second(s)
Initializing random number generator from current time


Initializing worker threads...

Threads started!

[ 20s ] thds: 64 tps: 10.85 qps: 262.93 (r/w/o: 190.63/47.40/24.90) lat (ms,95%): 8638.96 err/s: 0.00 reconn/s: 0.00
[ 40s ] thds: 64 tps: 21.50 qps: 439.63 (r/w/o: 306.99/89.65/43.00) lat (ms,95%): 6026.41 err/s: 0.00 reconn/s: 0.00
[ 60s ] thds: 64 tps: 27.45 qps: 549.34 (r/w/o: 381.76/112.69/54.89) lat (ms,95%): 4280.32 err/s: 0.00 reconn/s: 0.00
[ 80s ] thds: 64 tps: 27.00 qps: 541.42 (r/w/o: 379.11/108.30/54.00) lat (ms,95%): 4280.32 err/s: 0.00 reconn/s: 0.00
[ 100s ] thds: 64 tps: 32.10 qps: 631.02 (r/w/o: 443.95/122.86/64.21) lat (ms,95%): 3574.99 err/s: 0.00 reconn/s: 0.00
[ 120s ] thds: 64 tps: 29.20 qps: 593.14 (r/w/o: 414.96/119.79/58.39) lat (ms,95%): 2728.81 err/s: 0.00 reconn/s: 0.00
[ 140s ] thds: 64 tps: 35.40 qps: 712.75 (r/w/o: 496.31/145.64/70.79) lat (ms,95%): 3326.55 err/s: 0.00 reconn/s: 0.00
[ 160s ] thds: 64 tps: 36.25 qps: 719.32 (r/w/o: 504.46/142.35/72.50) lat (ms,95%): 2985.89 err/s: 0.00 reconn/s: 0.00
[ 180s ] thds: 64 tps: 35.90 qps: 717.23 (r/w/o: 502.33/143.10/71.80) lat (ms,95%): 2159.29 err/s: 0.00 reconn/s: 0.00
[ 200s ] thds: 64 tps: 36.45 qps: 724.56 (r/w/o: 507.35/144.30/72.90) lat (ms,95%): 2728.81 err/s: 0.00 reconn/s: 0.00
[ 220s ] thds: 64 tps: 35.25 qps: 716.35 (r/w/o: 499.75/146.10/70.50) lat (ms,95%): 2009.23 err/s: 0.00 reconn/s: 0.00
[ 240s ] thds: 64 tps: 34.70 qps: 693.76 (r/w/o: 485.76/138.60/69.40) lat (ms,95%): 2985.89 err/s: 0.00 reconn/s: 0.00
[ 260s ] thds: 64 tps: 37.05 qps: 725.76 (r/w/o: 509.40/142.25/74.10) lat (ms,95%): 2585.31 err/s: 0.00 reconn/s: 0.00
[ 280s ] thds: 64 tps: 31.95 qps: 647.25 (r/w/o: 453.15/130.20/63.90) lat (ms,95%): 3208.88 err/s: 0.00 reconn/s: 0.00
[ 300s ] thds: 64 tps: 32.15 qps: 641.59 (r/w/o: 449.30/128.00/64.30) lat (ms,95%): 2362.72 err/s: 0.00 reconn/s: 0.00
SQL statistics:
    queries performed:
        read:                            130592
        write:                           37312
        other:                           18656
        total:                           186560
    transactions:                        9328   (30.99 per sec.)
    queries:                             186560 (619.85 per sec.)
    ignored errors:                      0      (0.00 per sec.)
    reconnects:                          0      (0.00 per sec.)

General statistics:
    total time:                          300.9748s
    total number of events:              9328

Latency (ms):
         min:                                   46.40
         avg:                                 2064.81
         max:                                10765.52
         95th percentile:                     3706.08
         sum:                             19260519.10

Threads fairness:
    events (avg/stddev):           145.7500/3.03
    execution time (avg/stddev):   300.9456/0.11

```

