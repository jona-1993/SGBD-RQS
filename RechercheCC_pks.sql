CREATE OR REPLACE PACKAGE RechercheCC AS
	
	date_drop INTERVAL DAY(3) TO SECOND (0);
	
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

	TYPE ReviewRecord IS RECORD 
	(
		movie review.movie%type,
		users review.users%type,
		cote review.cote%type,
		avis review.avis%type,
		review_date review.review_date%type
		
	);
	TYPE Reviews IS TABLE OF ReviewRecord INDEX BY BINARY_INTEGER;

	--Déclaration
	procedure Register(argnom in users.nom%type, argprenom in users.prenom%type, arglogin in users.login%type, argpasswd in users.password%type);
	
	procedure Authentication(arglogin in users.login%type, passwd in users.password%type);
	
	procedure GetFilmByID (numero IN NUMBER);

	procedure SerializeFilm(films in Movies);
	
	procedure SearchFilm(arg in varchar2);
	
	procedure Voter(username in review.users%type, idmovie in review.movie%type, note in review.cote%type, commentaire in review.avis%type);
	
	procedure GetVote(username in review.users%type, idmovie in review.movie%type);
	
	procedure Replication;
	
	procedure PurgeCC;
	
END RechercheCC;
/
show errors
