drop database if exists otus;

create database otus owner portaladmin;

create table people (
	id int64 primary key,
	fio	
	birth_date
	awards
	description
	
);

create table movies (
	id int64 primary key,
	title char(128), -- наименование картины
	director int64 fk, -- режисср
	produsers int64 m2m people, --продюсеры
	main_actors int64 m2m people, -- главные актеры
	actors int64 m2m people, -- актеры
	"release" date, -- дата выпуска
	budget money, -- бюджет картины
	boxoffice money,
	genre int64 fk genres, -- жанр 
	awards int64 m2m awards, -- количество оскаров -> через fk с таблицей с указанием номинации, года
	story text, -- сюжет
	description
);


