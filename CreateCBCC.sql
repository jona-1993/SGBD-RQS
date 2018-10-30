create table artist (
	id   number(7) 
		constraint artist$pk primary key,
	name varchar2(23 char) 
		constraint artist$name$nn not null
);

-- https://en.wikipedia.org/wiki/Motion_Picture_Association_of_America_film_rating_system
-- https://filmratings.com/Content/Downloads/mpaa_ratings-poster-qr.pdf
-- https://www.uecmovies.com/movies/ratings
-- https://filmratings.com/RatingsGuide
create table certification (
	id          number(1) generated always as identity
        	constraint cert$pk primary key,
	code        varchar2(5) 
        	constraint cert$code$nn not null 
        	constraint cert$code$value check (code in ('G', 'PG', 'PG-13', 'R', 'NC-17')),
        	constraint cert$code$un unique (code),
	name        varchar2(28) ,
	definition  varchar2(57), -- J'ai du ajouter +1 (Manquais 1 caractère)
	description varchar2(122)
);


create table status (
	id          number(1) generated always as identity
		constraint status$pk primary key,
	name        varchar2(15)
		constraint status$name$nn not null
		constraint status$name$un unique
		constraint status$name$value check (name in ('Post Production', 'Rumored', 'Released', 'In Production', 'Planned', 'Canceled'))
);


create table genre (
	id   number(5) constraint genre$pk primary key,
	name varchar2(15) 
        	constraint genre$name$nn not null
        	constraint genre$name$un unique
);

create table movie (
	id             number(6) 
        	constraint movie$pk primary key,
	title          varchar2(60 char)
		constraint movie$title$nn not null,
	original_title varchar2(60 char)
		constraint movie$original_title$nn not null,
	status         number(1)
		constraint movie$status$fk REFERENCES status(id),
	release_date   date constraint movie$release_date$date check(to_number(to_char(release_date, 'YYYY'), 9999) > 1894) -- Le premier film date de 1895 (Train qui arrives en gare)
		constraint movie$release_date$nn not null,
	vote_average   number(3,1)
		constraint movie$vote_average$number check(vote_average between 0 and 10)
		constraint movie$vote_average$nn not null,
	vote_count     number(5)
		constraint movie$vote_count$number check(vote_count>= 0)
		constraint movie$vote_count$nn not null,
	certification  number(1)
		constraint movie$certification$fk REFERENCES certification(id),
	runtime        number(3)
		constraint movie$runtime$number check(runtime>= 0)
		constraint movie$runtime$nn not null, -- minutes
	poster         blob default empty_blob()
);


create table movie_director (
	movie    number(6)
		constraint movie_director$movie$fk REFERENCES movie(id),
	director number(7)
		constraint movie_director$director$fk REFERENCES artist(id),
	constraint m_d$pk primary key (movie, director)
);

create table movie_genre (
	movie number(6)
		constraint movie_genre$movie$fk REFERENCES movie(id),
	genre number(5)
		constraint movie_genre$genre$fk REFERENCES genre(id),
	constraint m_g$pk primary key (genre, movie)
  ) ;

create table movie_actor (
	movie number(6)
		constraint movie_actor$movie$fk REFERENCES movie(id),
	actor number(7)
		constraint movie_actor$actor$fk REFERENCES artist(id),
	constraint m_a$pk primary key (movie, actor)
);




create table LogErreurs (
	id              integer generated always as identity,
	tracking        varchar2(128),
	who             varchar2(128),
	datetime        timestamp(6),
	message         varchar2(4000),
	code            integer,
	errm            varchar2(512),
	error_backtrace varchar2(2000),
	error_stack     varchar2(2000),
	constraint LogErreurs$PK primary key (id),
	constraint LogErreurs$who$NN check (who is not null),
	constraint LogErreurs$datetime$NN check (datetime is not null),
	constraint LogErreurs$code$NN
	check (code is not null or message is not null),
	constraint LogErreurs$errm$NN
	check (errm is not null or message is not null),
	constraint LogErreurs$error_backtrace$NN
	check (error_backtrace is not null or message is not null),
	constraint LogErreurs$error_stack$NN
	check (error_stack is not null or message is not null)
);

create table LogInfos (
	id       integer generated always as identity,
	tracking varchar2(128),
	who      varchar2(128),
	datetime timestamp(6),
	message  varchar2(4000),
	constraint LogInfos$PK primary key (id),
	constraint LogInfos$who$NN check (who is not null),
	constraint LogInfos$datetime$NN check (datetime is not null),
	constraint LogInfos$message$NN check (message is not null)
);

create table users
(
	login varchar2(20 char)
		constraint users$pk primary key,
	nom varchar2(20 char) 
		constraint users$nom$nn not null,
	prenom varchar2(20 char) 
		constraint users$prenom$nn not null,
	password varchar2(20 char) 
		constraint users$password$nn not null
);

create table review
(
	movie number(6) 
		constraint review$movie$fk references movie(id),
	users varchar2(20 char)
		constraint review$users$fk references users(login),
	cote number(2) 
		constraint review$cote$pos check (cote between 0 and 10)
		constraint review$cote$nn not null,
	avis varchar2(200 char),
	review_date date -- Triger date supp à la date actuelle
        	constraint review$review_date$nn not null,
	constraint review$pk primary key (movie, users)
);

