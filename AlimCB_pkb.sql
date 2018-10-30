create or replace package body AlimCB as

	-- Procédure Ajout Random
	procedure AjouterRand(Nb in number) as
		list list_id_movie;
		NegException Exception;
	begin
		if(Nb <= 0) then raise NegException; end if;
		select id bulk collect into list from (select id from movies_ext order by dbms_random.value) where rownum <= Nb;
		Ajouter(list);
	exception
		when NegException then raise_application_error(-20001, 'Le nombre d''éléments a prendre doit être > à 0');
		when others then raise;
	end AjouterRand;
	
	-- Procédure Ajouter
	
	procedure Ajouter (List IN list_id_movie) as
	
		ListeActeurs Artists;
		ListeDirectors Artists;
		ListeGenres Genres;
		ListeFilms Movies;
		
		retour varchar2(100);
		max_char number;
		id_certif number;
		id_status number;
		image blob default empty_blob();
		
	begin
	
		FOR i IN List.FIRST..List.LAST LOOP 

			ListeDirectors := Director(List(i)); 
			ListeActeurs := Acteur(List(i)); 
			ListeGenres := Genref(List(i));
			ListeFilms := Film(List(i));
		
			-- Vérification des champs pour la table artist et ajout
			FOR i IN 1 .. ListeActeurs.COUNT LOOP
				BEGIN
					SELECT char_length INTO max_char 
					FROM user_tab_columns t 
					WHERE t.table_name = 'ARTIST' 
					AND t.column_name = 'NAME';
				
					ListeActeurs(i).name := TRIM(ListeActeurs(i).name);
				
					IF(LENGTH(ListeActeurs(i).name) > max_char) THEN
						ListeActeurs(i).name := SUBSTR(ListeActeurs(i).name, 1, max_char - 3);
						ListeActeurs(i).name := CONCAT(ListeActeurs(i).name, '...');	
					END IF;
			
					INSERT INTO artist 
					VALUES(ListeActeurs(i).id, ListeActeurs(i).name) returning name into retour;
					log_pkg.LogInfo('Insert Actor: ' || retour, 'Ajouter');						
				EXCEPTION
					WHEN DUP_VAL_ON_INDEX THEN log_pkg.LogInfo('L''id de ' || retour || ' existe deja !', 'Ajouter (Actor)');
					WHEN OTHERS THEN log_pkg.LogErreur('Acteur', true, 'Ajouter'); rollback; raise;
				END;
			END LOOP;
		
			savepoint SaveActors;
			
			-- vérif Directors et ajout
			FOR i IN 1 .. ListeDirectors.COUNT LOOP
				BEGIN
					SELECT CHAR_LENGTH INTO max_char 
					FROM user_tab_columns t 
					WHERE t.table_name = 'ARTIST' 
					AND t.column_name = 'NAME';
				
					ListeDirectors(i).name := TRIM(ListeDirectors(i).name);
				
					IF(LENGTH(ListeDirectors(i).name) > max_char) THEN
						ListeDirectors(i).name := SUBSTR(ListeDirectors(i).name, 1, max_char - 3);
						ListeDirectors(i).name := CONCAT(ListeDirectors(i).name, '...');
					END IF;
		
					INSERT INTO artist 
					VALUES(ListeDirectors(i).id, ListeDirectors(i).name) returning name into retour;
					log_pkg.LogInfo('Insert Director: ' || retour, 'Ajouter');							
				EXCEPTION
					WHEN DUP_VAL_ON_INDEX THEN log_pkg.LogInfo('L''id de ' || retour || ' existe deja !', 'Ajouter (Directors)');
					WHEN OTHERS THEN log_pkg.LogErreur('Director', true, 'Ajouter'); rollback to SaveActors; raise;
				END;
				END LOOP;
		
		
			savepoint SaveDirectors;
		
			--vérif movie et ajout
		
			BEGIN
				SELECT CHAR_LENGTH INTO max_char 
				FROM user_tab_columns t 
				WHERE t.table_name = 'MOVIE' 
				AND t.column_name = 'TITLE';
			
				ListeFilms(1).title := TRIM(ListeFilms(1).title);
			
				IF(LENGTH(ListeFilms(1).title) > max_char) THEN
					ListeFilms(1).title := SUBSTR(ListeFilms(1).title, 1, max_char - 3);
					ListeFilms(1).title := CONCAT(ListeFilms(1).title, '...');
				END IF;
		
				SELECT CHAR_LENGTH INTO max_char 
				FROM user_tab_columns t 
				WHERE t.table_name = 'MOVIE' 
				AND t.column_name = 'ORIGINAL_TITLE';
			
				ListeFilms(1).original_title := TRIM(ListeFilms(1).original_title);
			
				IF(LENGTH(ListeFilms(1).original_title) > max_char) THEN
					ListeFilms(1).original_title := SUBSTR(ListeFilms(1).original_title, 1, max_char - 3);
					ListeFilms(1).original_title := CONCAT(ListeFilms(1).original_title, '...');
				END IF;
			
			
				ListeFilms(1).certification := TRIM(ListeFilms(1).certification);
			
				CASE ListeFilms(1).certification
					WHEN 'G' THEN id_certif := 1;
					WHEN 'PG' THEN id_certif := 2;
					WHEN 'PG-13' THEN id_certif := 3;
					WHEN 'R' THEN id_certif := 4;
					WHEN 'NC-17' THEN id_certif := 5;
				ELSE id_certif := null;
				END CASE;
			
			
				ListeFilms(1).status := TRIM(ListeFilms(1).status);
			
				CASE ListeFilms(1).status
					WHEN 'Canceled' THEN id_status := 1;
					WHEN 'In Production' THEN id_status := 2;
					WHEN 'Planned' THEN id_status := 3;
					WHEN 'Post Production' THEN id_status := 4;
					WHEN 'Released' THEN id_status := 5;
					WHEN 'Rumored' THEN id_status := 6;
				ELSE id_status := null;
				END CASE;
		
				-- Récupération du blob (poster)
				BEGIN
					image := httpuritype.createuri(CONCAT('http://image.tmdb.org/t/p/w185', ListeFilms(1).poster)).getblob();
		
		log_pkg.LogInfo('Poster trouvé à l''adresse: ' || 'http://image.tmdb.org/t/p/w185' || ListeFilms(1).poster, 'Ajouter');	
			
				EXCEPTION 
			
					WHEN OTHERS THEN log_pkg.LogErreur('Movie_poster', true, 'Ajouter');
				END;
			
			
				INSERT INTO movie 
					VALUES(ListeFilms(1).id, ListeFilms(1).title, ListeFilms(1).original_title, 
					id_status, ListeFilms(1).release_date, 
					ListeFilms(1).vote_average, ListeFilms(1).vote_count, id_certif, 
					ListeFilms(1).runtime, image) returning title into retour;
				
				log_pkg.LogInfo('Film insert: ' || retour, 'Ajouter');
			
		
				-- références directeur et movie
				FOR i IN 1 .. ListeDirectors.COUNT LOOP
					BEGIN
						INSERT INTO movie_director 
						VALUES(ListeFilms(1).id, ListeDirectors(i).id);
					
					EXCEPTION
			
						WHEN OTHERS THEN  rollback to SaveDirectors; log_pkg.LogErreur('Movie_Director: Le film ne sera pas ajouté', true, 'Ajouter'); raise;
					END;
				END LOOP;
	
				log_pkg.LogInfo('Insert movie_director: OK', 'Ajouter');
			
				-- références acteur et movie
				FOR i IN 1 .. ListeActeurs.COUNT LOOP
					BEGIN
						INSERT INTO movie_actor 
						VALUES(ListeFilms(1).id, ListeActeurs(i).id);
					
					EXCEPTION
						WHEN OTHERS THEN  rollback to SaveDirectors; log_pkg.LogErreur('Movie_Actor: Le film ne sera pas ajouté', true, 'Ajouter'); raise;
					END;
				END LOOP;
	
				log_pkg.LogInfo('Insert Movie_actor: OK', 'Ajouter');
			
				--références genre et movie
				FOR i IN 1 .. ListeGenres.COUNT LOOP
					BEGIN
						INSERT INTO movie_genre VALUES(ListeFilms(1).id, ListeGenres(i).id);
					
					EXCEPTION
						WHEN OTHERS THEN rollback to SaveDirectors; log_pkg.LogErreur('Movie_Genre: Le film ne sera pas ajouté', true, 'Ajouter'); raise;
					END;
				END LOOP;
			EXCEPTION
	
				WHEN OTHERS THEN rollback to SaveDirectors; log_pkg.LogErreur('Film', true, 'Ajouter'); raise;
			END;
		
			log_pkg.LogInfo('Insert Movie_genre: OK', 'Ajouter');
		
			log_pkg.LogInfo(retour || ' a été validé', 'Ajouter');
		
			commit;
		END LOOP;
		
	EXCEPTION
		WHEN OTHERS THEN rollback; raise;
	END Ajouter;	
	
	--Fonction Acteur
	FUNCTION Acteur (identifiant movie.id%type) RETURN Artists IS TableArtist Artists;
		id varchar(10 char);
		name varchar(200 char);
		idNullException EXCEPTION;
		NoActorException EXCEPTION;
	BEGIN 
		IF (identifiant is NULL) THEN RAISE idNullException; END IF;

		--Récupération de l'id et du nom de l'acteur
		SELECT * BULK COLLECT INTO TableArtist FROM (
		with temp (chaine, start_pos, end_pos) as 
		( 
			select actors, 1,  instr(ACTORS, '‖' , 1) from movies_ext where id = identifiant
			union all
			select chaine, end_pos + 1, instr(chaine, '‖' , end_pos + 1) from temp where end_pos != 0
		)
		select distinct substr(substr(chaine, start_pos, (Case When end_pos = 0 Then length(chaine) + 1 else end_pos end) - start_pos), 
				1, instr(substr(chaine, start_pos, (Case When end_pos = 0 Then length(chaine) + 1 else end_pos end) - start_pos), 
				'․', 1) -1)as id, replace(regexp_substr((substr(substr(chaine, start_pos, 
				(Case When end_pos = 0 Then length(chaine) + 1 else end_pos end) - start_pos), instr(substr(chaine, start_pos, 
				(Case When end_pos = 0 Then length(chaine) + 1 else end_pos end) - start_pos), '․', 1) +1,
				Case When end_pos = 0 Then length(chaine) + 1 else end_pos end - instr(substr(chaine, start_pos, 
				(Case When end_pos = 0 Then length(chaine) + 1 else end_pos end) - start_pos),'․', 1) -1)), '[^․]*․?', 1, 1) ,'․') as name 
		from temp);
        
		IF(TableArtist.COUNT is null) THEN RAISE NoActorException;END IF;

		RETURN TableArtist;
	EXCEPTION 
		when idNullException THEN log_pkg.LogErreur('id: ' || identifiant, true, 'Acteur'); commit; raise;
		when NoActorException THEN log_pkg.LogInfo('Pas d''acteur pour l''id ' || identifiant, 'Acteur'); commit;
		WHEN OTHERS THEN log_pkg.LogErreur('id: ' || identifiant, true, 'Acteur'); commit; 
	END Acteur;
	
	--Fontion Directeur
	FUNCTION Director (identifiant movie.id%type) RETURN Artists IS TableArtist Artists;
		id varchar(10 char);
		name varchar(200 char);
		idNullException EXCEPTION;
		NoDirectorException EXCEPTION;
	BEGIN 
		IF (identifiant is NULL) THEN RAISE idNullException; END IF;

		--Récupération de l'id et du nom du directeur
		SELECT * BULK COLLECT INTO TableArtist FROM (
		with temp (chaine, start_pos, end_pos) as 
		( 
			select directors, 1,  instr(DIRECTORS, '‖' , 1) from movies_ext where id = identifiant
			union all
			select chaine, end_pos + 1, instr(chaine, '‖' , end_pos + 1) from temp where end_pos != 0
		)
		select distinct substr(substr(chaine, start_pos, (Case When end_pos = 0 Then length(chaine) + 1 else end_pos end) - start_pos), 
				1, instr(substr(chaine, start_pos, (Case When end_pos = 0 Then length(chaine) + 1 else end_pos end) - start_pos), 
				'․', 1) -1)as id, substr(substr(chaine, start_pos, 
				(Case When end_pos = 0 Then length(chaine) + 1 else end_pos end) - start_pos), instr(substr(chaine, start_pos, 
				(Case When end_pos = 0 Then length(chaine) + 1 else end_pos end) - start_pos), '․', 1) +1,
			   	Case When end_pos = 0 Then length(chaine) + 1 else end_pos end - instr(substr(chaine, start_pos, 
			   	(Case When end_pos = 0 Then length(chaine) + 1 else end_pos end) - start_pos),'․', 1) -1) as name
		from temp);

		IF(TableArtist.COUNT is null) THEN RAISE NoDirectorException;END IF;

		RETURN TableArtist;
	EXCEPTION 
		when idNullException THEN log_pkg.LogErreur('id: ' || identifiant, true, 'Director'); commit;  raise;
		when NoDirectorException THEN log_pkg.LogInfo('Pas de director pour l''id ' || identifiant, 'Director'); commit; 
		WHEN OTHERS THEN log_pkg.LogErreur('id: ' || identifiant, true, 'Director'); commit; 
	END Director;
	
	--Fonction Films
	FUNCTION Film (identifiant movie.id%type) RETURN Movies IS TableFilm Movies;
		idNullException EXCEPTION;
	BEGIN 
		IF (identifiant is NULL) THEN RAISE idNullException; END IF;

		SELECT id, title, original_title, status, release_date, vote_average, vote_count, certification, runtime, poster_path 
		BULK COLLECT INTO TableFilm
		FROM movies_ext
		WHERE id = identifiant;
		
		RETURN TableFilm;
	EXCEPTION 
		WHEN idNullException then log_pkg.LogErreur('id ' || identifiant, true, 'Film'); commit;  raise;
		WHEN OTHERS THEN log_pkg.LogErreur('id: ' || identifiant, true, 'Film'); raise; commit; 
	END Film;
	
	-- Fonction GenreF
	
	FUNCTION GenreF (identifiant movie.id%type) RETURN Genres IS TableGenre Genres;
		id varchar(10 char);
		name varchar(200 char);
		idNullException EXCEPTION;
		NoGenreException EXCEPTION;
	BEGIN 
		IF (identifiant is NULL) THEN RAISE idNullException; END IF;

		
		SELECT * BULK COLLECT INTO TableGenre FROM (
		with temp (chaine, start_pos, end_pos) as 
		( 
			select genres, 1,  instr(genres, '‖' , 1) from movies_ext where id = identifiant
			union all
			select chaine, end_pos + 1, instr(chaine, '‖' , end_pos + 1) from temp where end_pos != 0
		)
		select distinct substr(substr(chaine, start_pos, (Case When end_pos = 0 Then length(chaine) + 1 else end_pos end) - start_pos), 
				1, instr(substr(chaine, start_pos, (Case When end_pos = 0 Then length(chaine) + 1 else end_pos end) - start_pos),
				'․', 1) -1)as id, substr(substr(chaine, start_pos, 
				(Case When end_pos = 0 Then length(chaine) + 1 else end_pos end) - start_pos), 
				 instr(substr(chaine, start_pos, 
				(Case When end_pos = 0 Then length(chaine) + 1 else end_pos end) - start_pos), '․', 1) +1,
				Case When end_pos = 0 Then length(chaine) + 1 else end_pos end - instr(substr(chaine, start_pos, 
				(Case When end_pos = 0 Then length(chaine) + 1 else end_pos end) - start_pos),'․', 1) -1) as name
			
		from temp);
		
		
		IF(TableGenre.COUNT is null) THEN RAISE NoGenreException;END IF;
		
		RETURN TableGenre;
	EXCEPTION 
		when idNullException THEN log_pkg.LogErreur('id: ' || identifiant, true, 'GenreF'); commit;  raise;
		when NoGenreException THEN log_pkg.LogInfo('Pas de genres pour l''id ' || identifiant, 'GenreF'); commit; 
		WHEN OTHERS THEN log_pkg.LogErreur('id: ' || identifiant, true, 'GenreF'); commit; 
	END GenreF;
	
		
end AlimCB;
/
show errors
