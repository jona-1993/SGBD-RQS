CREATE OR REPLACE PACKAGE AlimCB AS

	TYPE list_id_movie IS VARRAY(100) OF NUMBER(6);

	TYPE Genres IS TABLE OF genre%rowtype INDEX BY BINARY_INTEGER;
	
	TYPE ArtistRecord IS RECORD
	(
		id artist.id%type,
		name artist.name%type
	);
    
	TYPE Artists IS TABLE OF ArtistRecord INDEX BY BINARY_INTEGER;

	TYPE MovieRecord IS RECORD 
	(
		id movies_ext.id%type,
		title movies_ext.title%type,
		original_title movies_ext.original_title%type,
		status movies_ext.status%type,
		release_date movies_ext.release_date%type,
		vote_average movies_ext.vote_average%type,
		vote_count movies_ext.vote_count%type,
		certification movies_ext.certification%type,
		runtime movies_ext.runtime%type,
		poster movies_ext.poster_path%type
	);
	TYPE Movies IS TABLE OF MovieRecord INDEX BY BINARY_INTEGER;

	--Déclaration
	PROCEDURE Ajouter (List IN list_id_movie);

	PROCEDURE AjouterRand (Nb IN NUMBER);

    	FUNCTION Acteur (identifiant movie.id%type) RETURN Artists;

	FUNCTION Director (identifiant movie.id%type) RETURN Artists;
	
    	FUNCTION Film (identifiant movie.id%type) RETURN Movies;

	FUNCTION GenreF (identifiant movie.id%type) RETURN Genres;
	
END AlimCB;
/
show errors
