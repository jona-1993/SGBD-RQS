CREATE OR REPLACE PACKAGE RechercheCC AS
	
	TYPE MovieRecord IS RECORD 
	(
		id movie.id%type,
		title movie.title%type,
		original_title movie.original_title%type,
		status movie.status%type,
		release_date movie.release_date%type,
		vote_average movie.vote_average%type,
		vote_count movie.vote_count%type,
		certification movie.certification%type,
		runtime movie.runtime%type,
		poster movie.poster%type
	);
	TYPE Movies IS TABLE OF MovieRecord INDEX BY BINARY_INTEGER;

	--Déclaration
	procedure GetFilmByID (numero IN NUMBER);

	procedure SerializeFilm(films in Movies);
	
	procedure SearchFilm(arg in varchar2);
	
END RechercheCC;
/
show errors
