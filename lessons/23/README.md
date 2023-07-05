# MongoDB

## Установка MongoDB
### Загрузка образа
```shell
➜  ~ docker pull mongo
Using default tag: latest
latest: Pulling from library/mongo
9d19ee268e0d: Pull complete
84c1327991fa: Pull complete
1feec59ecd14: Pull complete
3af7480eaf55: Pull complete
d7524ee16ced: Pull complete
f4742175eefc: Pull complete
9d688a8d9c18: Pull complete
b24ebfb25f44: Pull complete
0ee52198e640: Pull complete
Digest: sha256:bf1d25bae7c2fd47cd9a89eec3db08e73ccfbef666e43f583fa6b560ca07ac5a
Status: Downloaded newer image for mongo:latest
docker.io/library/mongo:latest

```
### Запуск сервера
```shell
➜  ~ docker run -d --name mongodb -v mongodata:/data/db -p 27017:27017 mongo
689afc2fddb4c712428832b1ea991c5de640c5aaefa8c82be45c561c16131c06
➜  ~ docker ps -a
CONTAINER ID   IMAGE     COMMAND                  CREATED         STATUS         PORTS                                           NAMES
689afc2fddb4   mongo     "docker-entrypoint.s…"   5 seconds ago   Up 3 seconds   0.0.0.0:27017->27017/tcp, :::27017->27017/tcp   mongodb
```
### Вход в консоль docker mongo
```shell
➜  ~ docker exec -it mongodb bash
root@689afc2fddb4:/# mongosh
Current Mongosh Log ID:	64a58ee80e651e5c4e5fa16e
Connecting to:		mongodb://127.0.0.1:27017/?directConnection=true&serverSelectionTimeoutMS=2000&appName=mongosh+1.10.1
Using MongoDB:		6.0.7
Using Mongosh:		1.10.1

For mongosh info see: https://docs.mongodb.com/mongodb-shell/


To help improve our products, anonymous usage data is collected and sent to MongoDB periodically (https://www.mongodb.com/legal/privacy-policy).
You can opt-out by running the disableTelemetry() command.

------
   The server generated these startup warnings when booting
   2023-07-05T15:37:19.532+00:00: Using the XFS filesystem is strongly recommended with the WiredTiger storage engine. See http://dochub.mongodb.org/core/prodnotes-filesystem
   2023-07-05T15:37:20.238+00:00: Access control is not enabled for the database. Read and write access to data and configuration is unrestricted
   2023-07-05T15:37:20.239+00:00: /sys/kernel/mm/transparent_hugepage/enabled is 'always'. We suggest setting it to 'never'
   2023-07-05T15:37:20.239+00:00: vm.max_map_count is too low
------
```
### Получение списка баз
```shell
test> show dbs
admin   40.00 KiB
config  12.00 KiB
local   40.00 KiB
test> use stud
switched to db stud
stud> db.createCollection('students')
{ ok: 1 }
stud>
```
### Вставка данных
```shell
stud> db.students.insertOne({"_id":0,"name":"aimee Zank","scores":[{"score":1.463179736705023,"type":"exam"},{"score":11.78273309957772,"type":"quiz"},{"score":35.8740349954354,"type":"homework"}]})
{ acknowledged: true, insertedId: 0 }
stud> db.students.insertOne({"_id":1,"name":"Aurelia Menendez","scores":[{"score":60.06045071030959,"type":"exam"},{"score":52.79790691903873,"type":"quiz"},{"score":71.76133439165544,"type":"homework"}]})
{ acknowledged: true, insertedId: 1 }
stud> db.students.insertMany([{"_id":2,"name":"Corliss Zuk","scores":[{"score":67.03077096065002,"type":"exam"},{"score":6.301851677835235,"type":"quiz"},{"score":66.28344683278382,"type":"homework"}]},{"_id":3,"name":"Bao Ziglar","scores":[{"score":71.64343899778332,"type":"exam"},{"score":24.80221293650313,"type":"quiz"},{"score":42.26147058804812,"type":"homework"}]},
... {"_id":4,"name":"Zachary Langlais","scores":[{"score":78.68385091304332,"type":"exam"},{"score":90.2963101368042,"type":"quiz"},{"score":34.41620148042529,"type":"homework"}]},{"_id":5,"name":"Wilburn Spiess","scores":[{"score":44.87186330181261,"type":"exam"},{"score":25.72395114668016,"type":"quiz"},{"score":63.42288310628662,"type":"homework"}]},
... {"_id":6,"name":"Jenette Flanders","scores":[{"score":37.32285459166097,"type":"exam"},{"score":28.32634976913737,"type":"quiz"},{"score":81.57115318686338,"type":"homework"}]},{"_id":7,"name":"Salena Olmos","scores":[{"score":90.37826509157176,"type":"exam"},{"score":42.48780666956811,"type":"quiz"},{"score":96.52986171633331,"type":"homework"}]},
... {"_id":8,"name":"Daphne Zheng","scores":[{"score":22.13583712862635,"type":"exam"},{"score":14.63969941335069,"type":"quiz"},{"score":75.94123677556644,"type":"homework"}]},{"_id":9,"name":"Sanda Ryba","scores":[{"score":97.00509953654694,"type":"exam"},{"score":97.80449632538915,"type":"quiz"},{"score":25.27368532432955,"type":"homework"}]},
... {"_id":10,"name":"Denisha Cast","scores":[{"score":45.61876862259409,"type":"exam"},{"score":98.35723209418343,"type":"quiz"},{"score":55.90835657173456,"type":"homework"}]},{"_id":11,"name":"Marcus Blohm","scores":[{"score":78.42617835651868,"type":"exam"},{"score":82.58372817930675,"type":"quiz"},{"score":87.49924733328717,"type":"homework"}]},
... {"_id":12,"name":"Quincy Danaher","scores":[{"score":54.29841278520669,"type":"exam"},{"score":85.61270164694737,"type":"quiz"},{"score":80.40732356118075,"type":"homework"}]},{"_id":13,"name":"Jessika Dagenais","scores":[{"score":90.47179954427436,"type":"exam"},{"score":90.3001402468489,"type":"quiz"},{"score":95.17753772405909,"type":"homework"}]}])
{
  acknowledged: true,
  insertedIds: {
    '0': 2,
    '1': 3,
    '2': 4,
    '3': 5,
    '4': 6,
    '5': 7,
    '6': 8,
    '7': 9,
    '8': 10,
    '9': 11,
    '10': 12,
    '11': 13
  }
stud> db.students.insertOne({"_id":14,"name":"Alix Sherrill","scores":[{"score":25.15924151998215,"type":"exam"},{"score":68.64484047692098,"type":"quiz"},{"score":24.68462152686763,"type":"homework"}]})
{ acknowledged: true, insertedId: 14 }

stud> show dbs
admin    40.00 KiB
config  108.00 KiB
local    40.00 KiB
stud     72.00 KiB
stud>
```
### Поиск данных
```shell
stud> db.students.findOne()
{
  _id: 0,
  name: 'aimee Zank',
  scores: [
    { score: 1.463179736705023, type: 'exam' },
    { score: 11.78273309957772, type: 'quiz' },
    { score: 35.8740349954354, type: 'homework' }
  ]
}
```

```shell
stud> db.students.find({name: 'Alix Sherrill'})
[
  {
    _id: 14,
    name: 'Alix Sherrill',
    scores: [
      { score: 25.15924151998215, type: 'exam' },
      { score: 68.64484047692098, type: 'quiz' },
      { score: 24.68462152686763, type: 'homework' }
    ]
  }
]
```

```shell
stud> db.students.find({"_id": {$gt: 12}})
[
  {
    _id: 13,
    name: 'Jessika Dagenais',
    scores: [
      { score: 90.47179954427436, type: 'exam' },
      { score: 90.3001402468489, type: 'quiz' },
      { score: 95.17753772405909, type: 'homework' }
    ]
  },
  {
    _id: 14,
    name: 'Alix Sherrill',
    scores: [
      { score: 25.15924151998215, type: 'exam' },
      { score: 68.64484047692098, type: 'quiz' },
      { score: 24.68462152686763, type: 'homework' }
    ]
  }
]
```

```shell
stud> db.students.find({})
[
  {
    _id: 0,
    name: 'aimee Zank',
    scores: [
      { score: 1.463179736705023, type: 'exam' },
      { score: 11.78273309957772, type: 'quiz' },
      { score: 35.8740349954354, type: 'homework' }
    ]
  },
  {
    _id: 1,
    name: 'Aurelia Menendez',
    scores: [
      { score: 60.06045071030959, type: 'exam' },
      { score: 52.79790691903873, type: 'quiz' },
      { score: 71.76133439165544, type: 'homework' }
    ]
  },
  {
    _id: 2,
    name: 'Corliss Zuk',
    scores: [
      { score: 67.03077096065002, type: 'exam' },
      { score: 6.301851677835235, type: 'quiz' },
      { score: 66.28344683278382, type: 'homework' }
    ]
  },
  {
    _id: 3,
    name: 'Bao Ziglar',
    scores: [
      { score: 71.64343899778332, type: 'exam' },
      { score: 24.80221293650313, type: 'quiz' },
      { score: 42.26147058804812, type: 'homework' }
    ]
  },
  {
    _id: 4,
    name: 'Zachary Langlais',
    scores: [
      { score: 78.68385091304332, type: 'exam' },
      { score: 90.2963101368042, type: 'quiz' },
      { score: 34.41620148042529, type: 'homework' }
    ]
  },
  {
    _id: 5,
    name: 'Wilburn Spiess',
    scores: [
      { score: 44.87186330181261, type: 'exam' },
      { score: 25.72395114668016, type: 'quiz' },
      { score: 63.42288310628662, type: 'homework' }
    ]
  },
  {
    _id: 6,
    name: 'Jenette Flanders',
    scores: [
      { score: 37.32285459166097, type: 'exam' },
      { score: 28.32634976913737, type: 'quiz' },
      { score: 81.57115318686338, type: 'homework' }
    ]
  },
  {
    _id: 7,
    name: 'Salena Olmos',
    scores: [
      { score: 90.37826509157176, type: 'exam' },
      { score: 42.48780666956811, type: 'quiz' },
      { score: 96.52986171633331, type: 'homework' }
    ]
  },
  {
    _id: 8,
    name: 'Daphne Zheng',
    scores: [
      { score: 22.13583712862635, type: 'exam' },
      { score: 14.63969941335069, type: 'quiz' },
      { score: 75.94123677556644, type: 'homework' }
    ]
  },
  {
    _id: 9,
    name: 'Sanda Ryba',
    scores: [
      { score: 97.00509953654694, type: 'exam' },
      { score: 97.80449632538915, type: 'quiz' },
      { score: 25.27368532432955, type: 'homework' }
    ]
  },
  {
    _id: 10,
    name: 'Denisha Cast',
    scores: [
      { score: 45.61876862259409, type: 'exam' },
      { score: 98.35723209418343, type: 'quiz' },
      { score: 55.90835657173456, type: 'homework' }
    ]
  },
  {
    _id: 11,
    name: 'Marcus Blohm',
    scores: [
      { score: 78.42617835651868, type: 'exam' },
      { score: 82.58372817930675, type: 'quiz' },
      { score: 87.49924733328717, type: 'homework' }
    ]
  },
  {
    _id: 12,
    name: 'Quincy Danaher',
    scores: [
      { score: 54.29841278520669, type: 'exam' },
      { score: 85.61270164694737, type: 'quiz' },
      { score: 80.40732356118075, type: 'homework' }
    ]
  },
  {
    _id: 13,
    name: 'Jessika Dagenais',
    scores: [
      { score: 90.47179954427436, type: 'exam' },
      { score: 90.3001402468489, type: 'quiz' },
      { score: 95.17753772405909, type: 'homework' }
    ]
  },
  {
    _id: 14,
    name: 'Alix Sherrill',
    scores: [
      { score: 25.15924151998215, type: 'exam' },
      { score: 68.64484047692098, type: 'quiz' },
      { score: 24.68462152686763, type: 'homework' }
    ]
  }
]
stud>
```
### Обновление данных
```shell
stud> db.students.updateOne({_id: 14}, {$set: {name: "Alex Sherrill"}})
{
  acknowledged: true,
  insertedId: null,
  matchedCount: 1,
  modifiedCount: 1,
  upsertedCount: 0
}
stud> db.students.find({name: 'Alex Sherrill'})
[
  {
    _id: 14,
    name: 'Alex Sherrill',
    scores: [
      { score: 25.15924151998215, type: 'exam' },
      { score: 68.64484047692098, type: 'quiz' },
      { score: 24.68462152686763, type: 'homework' }
    ]
  }
]
stud>

```
