create or replace package body RechercheCC as

	procedure Authentication(arglogin in users.login%type, passwd in users.password%type) as
		authenticated number;
		loginfiltred users.login%type;
		passwordfiltred users.password%type;
		too_much_results exception; -- Si il y a une injection SQL qui passe, je sais comment il y est parvenu
		begin
			-- éviter le SQL Injection au mieux
			select regexp_replace(arglogin, '\*|''|\;|\%|\.', '0') into loginfiltred from dual;
			select regexp_replace(passwd, '\*|''|\;|\%|\.', '0') into passwordfiltred from dual;
			
			select count(*) into authenticated from users where login like loginfiltred and password like passwordfiltred;
			if(authenticated = 1) then
				log_pkg.LogInfo('Authentifié: ' || arglogin, 'Authentication');
				htb.send('application/json', 200);
			elsif(authenticated = 0) then
				log_pkg.LogInfo('Accès refusé: ' || arglogin, 'Authentication');
				htb.send('application/json', 403); -- 403 = Accès refusé
			else
				raise too_much_results;
			end if;
		exception
			when too_much_results then log_pkg.LogErreur('Trop de tuples retourné - LOG= ' || arglogin || 'PASS= ' || passwd, true, 'Authentication'); raise_application_error(-20600, 'Une erreur louche est survenue !');
			when others then raise;
	end Authentication;
	
	procedure Register(argnom in users.nom%type, argprenom in users.prenom%type, arglogin in users.login%type, argpasswd in users.password%type) as
		created users.login%type;
		loginfiltred users.login%type;
		passwordfiltred users.password%type;
		erreursyntaxesql exception;
		begin
			-- éviter le SQL Injection au mieux
			select regexp_replace(arglogin, '\*|''|\;|\%|\.', '0') into loginfiltred from dual;
			select regexp_replace(argpasswd, '\*|''|\;|\%|\.', '0') into passwordfiltred from dual;
			
			if arglogin not like loginfiltred or argpasswd not like passwordfiltred then
				raise erreursyntaxesql;
			end if;
			
			insert into users values (arglogin, argnom, argprenom, argpasswd) returning login into created;
			
            commit;
            
			if(length(created) > 0) then
				log_pkg.LogInfo('Compte créé: ' || created, 'Register');
				htb.send('application/json', 200);
			else
				log_pkg.LogInfo('Compte non créé: ' || arglogin, 'Register');
				htb.send('application/json', 403); -- 403 = Accès refusé
			end if;
            
		exception
			when erreursyntaxesql then log_pkg.LogErreur('Syntaxe sql dans - LOG= ' || arglogin || 'PASS= ' || argpasswd, true, 'Register'); raise_application_error(-20500, 'De la syntaxe sql est dans l''id ou le password');
			when others then rollback; log_pkg.LogErreur('Erreur autre', true, 'Register'); raise;
	end Register;
	
	procedure GetFilmById(numero in number) as
        retour varchar2(100);
        status_name status.name%type;
        film Movies;
		liste ALIMCB.list_id_movie@to_cb;
		nb_result number;
		NegException Exception;
        begin
            if(numero <= 0) then raise NegException; end if;
            
            select count(*) into nb_result from movie where id = numero;
            
            if nb_result < 1 then
                SELECT numero BULK COLLECT INTO liste FROM dual;
                ALIMCB.Ajouter@to_cb(liste);
                    
                insert into movie (select * from movie@to_cb where id = numero);
                log_pkg.LogInfo('Insere movie: ' || retour, 'GetFilmById');
                insert into artist (
                    select artist.id, artist.name from movie@to_cb, movie_actor@to_cb, artist@to_cb 
                    where movie.id = numero 
                    and movie.id = movie_actor.movie
                    and movie_actor.actor = artist.id
                    union
                    select artist.id, artist.name from movie@to_cb, movie_director@to_cb, artist@to_cb 
                    where movie.id = numero 
                    and movie.id = movie_director.movie
                    and movie_director.director = artist.id);
                log_pkg.LogInfo('Insere artists: ' || retour, 'GetFilmById');
                insert into movie_genre (select movie.id, movie_genre.genre from movie@to_cb, movie_genre@to_cb where movie.id = movie_genre.movie and id = numero);
                
                log_pkg.LogInfo('Insere movie_genre: ' || retour, 'GetFilmById');
                insert into movie_actor (select movie.id, movie_actor.actor from movie@to_cb, movie_actor@to_cb where movie.id = movie_actor.movie and id = numero);
                
                log_pkg.LogInfo('Insere movie_actor: ' || retour, 'GetFilmById');
                insert into movie_director (select movie.id, movie_director.director from movie@to_cb, movie_director@to_cb where movie.id = movie_director.movie and id = numero);
                
                log_pkg.LogInfo('Insere movie_director: ' || retour, 'GetFilmById');
                
                commit;
                log_pkg.LogInfo('Film validé', 'GetFilmById');
            end if;
            
            select * bulk collect into film from movie where id = numero;
            
            select status.name into status_name from status where id = film(1).status;
            
            htb.append_nl('{');
            htb.append_nl('"title": "' || film(1).title || '",');
            htb.append_nl('"original_title": "' || film(1).original_title || '",');
            if film(1).status is not null then
                htb.append_nl('"status": "' || status_name || '",');
            else
                htb.append_nl('"status": null,');
            end if;
            htb.append_nl('"release_date": "' || to_char(film(1).release_date, 'DD/MM/YYYY') || '"');
            htb.append_nl('}');
            htb.send('application/json', 200);
            log_pkg.LogInfo('Film envoyé en json: ' || film(1).title, 'GetFilmById');
        exception
            when NegException then log_pkg.LogErreur('NEGATIF', true, 'GetFilmById'); raise_application_error(-20001, 'Le numero doit être > à 0');
            when others then rollback; log_pkg.LogErreur('OTHERS', true, 'GetFilmById'); rollback; raise;
	end GetFilmById;

	procedure SerializeFilm(films in Movies) as
		c sys_refcursor;
        begin
            
            apex_json.open_object;
            
            open c for
            select
                movie.id "id",
                movie.title "title",
                movie.original_title "original_title",
                to_char(movie.release_date, 'DD/MM/YYYY') "release_date",
                movie.vote_average "vote_average",
                movie.vote_count "vote_count",
                movie.runtime "runtime",
                apex_web_service.blob2clobbase64(movie.poster) "poster", -- Conversion du blob en clob base64
                cursor(
                select genre.id "id", genre.name "name"
                from genre, movie_genre where movie_genre.movie = films.id and movie_genre.genre = genre.id
            ) "genres",
                cursor(
                select artist.id "id", artist.name "name"
                from artist, movie_actor where movie_actor.movie = films.id and movie_actor.actor = artist.id
            ) "acteurs",
                cursor(
                select artist.id "id", artist.name "name"
                from artist, movie_director where movie_director.movie = films.id and movie_director.director = artist.id
            ) "realisateurs",
                cursor(
                    select certification.id "id", certification.code "code", certification.name "name", certification.definition "definition", certification.description "description"
                    from certification, movie where movie.id = films.id and certification.id = movie.certification
                ) "certifications",
                cursor(
                    select status.id "id", status.name "name"
                    from status, movie where movie.id = films.id and status.id = movie.status
                ) "status"
            from movie, table(films) films where movie.id = films.id
            order by movie.id;
            
            apex_json.write(c);
            
            apex_json.close_object;
            log_pkg.LogInfo('Nombre de films sérialisés: ' || films.count, 'SerializeFilm');
        exception
            when others then log_pkg.LogErreur('Erreur survenue, aucun film sera sérialisé', true, 'SerializeFilm'); raise;
	end SerializeFilm;
	
	procedure SearchFilm(arg in varchar2) as
        films Movies;
        compare_char varchar(2);
        actors varchar(200);
        titles movie.title%type;
        directors varchar(200);
        dates varchar(12);
        
        begin
            
            -- Récupération des différents critères envoyés en paramètre
            select regexp_replace(regexp_substr(arg, 'ACTORS=\[(.*?)\]'), 'ACTORS=|\[|\]', '') into actors from dual;
            select regexp_replace(regexp_substr(arg, 'TITLE=\[(.*?)\]'), 'TITLE=|\[|\]', '') into titles from dual;
            select regexp_replace(regexp_substr(arg, 'DIRECTORS=\[(.*?)\]'), 'DIRECTORS=|\[|\]', '') into directors from dual;
            select regexp_replace(regexp_substr(arg, 'DATE=\[(.*?)\]'), 'DATE=|\[|\]', '') into dates from dual;
            
            log_pkg.LogInfo('Actions: ' || 'A=' || actors || ';T=' || titles || 'DIR=' || directors || 'DATE=' || dates, 'SearchFilm');
            
            if(length(titles) > 0) then  -- Histoire d'éviter de tout rechercher si on a pas mentionné de titre
                select '%' || titles || '%' into titles from dual;
            end if;
            
            -- Récupération des films dont les critères sont acteurs, title ou directors
            select distinct * bulk collect into films from movie 
            where id in
                (select movie -- actors
                        from movie_actor, artist 
                        where movie_actor.actor = artist.id 
                        and regexp_like(lower(artist.name), replace(lower(trim(actors)), ',', '|')
                ))
                or id in (select id from movie  -- title
                    where lower(title) like lower(trim(titles)) 
                    or lower(original_title) like lower(trim(titles)))
                or id in (select movie from movie_director, artist -- directors
                        where movie_director.director = artist.id 
                        and regexp_like(lower(artist.name), replace(lower(trim(directors)), ',', '|')));
                
            log_pkg.LogInfo('Films trouvés en premier lieu: ' || films.count, 'SearchFilm');
            
            if length(dates) > 0 then
                select substr(dates, 1, 2) into compare_char from dual; -- Les deux premiers caracères complètent le critère de date
                case compare_char -- (eq = equals, su = superieur, in = inférieur)
                    when 'eq' then select distinct movie.id, movie.title, movie.original_title, movie.status, movie.release_date, movie.vote_average, movie.vote_count, movie.certification, movie.runtime, movie.poster bulk collect into films from movie
                            where movie.id in (select films.id from table(films) films
                            union
                            select movie.id from movie where (to_date(to_char(movie.release_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') - to_date(substr(dates, 3, length(dates)), 'DD/MM/YYYY')) = 0);
                    when 'su' then select distinct movie.id, movie.title, movie.original_title, movie.status, movie.release_date, movie.vote_average, movie.vote_count, movie.certification, movie.runtime, movie.poster bulk collect into films from movie
                            where movie.id in (select films.id from table(films) films
                            union
                            select movie.id from movie where (to_date(to_char(movie.release_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') - to_date(substr(dates, 3, length(dates)), 'DD/MM/YYYY')) > 0);
                    when 'in' then select distinct movie.id, movie.title, movie.original_title, movie.status, movie.release_date, movie.vote_average, movie.vote_count, movie.certification, movie.runtime, movie.poster bulk collect into films from movie
                            where movie.id in (select films.id from table(films) films
                            union
                            select movie.id from movie where (to_date(to_char(movie.release_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') - to_date(substr(dates, 3, length(dates)), 'DD/MM/YYYY')) < 0);
                end case;
            end if;
            
            log_pkg.LogInfo('Films trouvés en second lieu: ' || films.count, 'SearchFilm');
                
            SerializeFilm(films);
            
        exception
            when others then log_pkg.LogErreur('Erreur inattendue est survenue', true, 'SearchFilm'); raise;
	end SearchFilm;
	
	procedure Voter(username in review.users%type, idmovie in review.movie%type, note in review.cote%type, commentaire in review.avis%type) as
		retour number;
		begin
			if note >= 0 then
				select count(*) into retour from review where users like username and movie = idmovie;
				if retour < 1 then 
					insert into review values(idmovie, username, note, commentaire, current_date);
					log_pkg.LogInfo('Vote ajouté avec succès pour ' || username, 'Voter');
				else
					update review set users = username, movie = idmovie, cote = note, avis = commentaire, review_date = current_date
					where users like username and movie = idmovie;
					log_pkg.LogInfo('Vote mis à jour avec succès pour ' || username, 'Voter');
					
				end if;
			else
				delete from review where users like username and movie = idmovie;
				log_pkg.LogInfo('Vote supprimé avec succès pour ' || username, 'Voter');
			end if;
			commit;
			htb.send('application/json', 200);
		exception
			when others then rollback; log_pkg.LogErreur('Erreur inattendue est survenue', true, 'Voter'); raise;
	end Voter;
	
	procedure GetVote(username in review.users%type, idmovie in review.movie%type) as
		vote reviews;
		begin
			select * bulk collect into vote from review where users = username and movie = idmovie;
			
			if(vote.count > 0) then
				htb.append_nl('{');
				htb.append_nl('"movie": ' || vote(1).movie || ',');
				htb.append_nl('"users": "' || vote(1).users || '",');
				htb.append_nl('"cote": ' || vote(1).cote || ',');
				htb.append_nl('"avis": "' || vote(1).avis || '",');
				htb.append_nl('"review_date": "' || to_char(vote(1).review_date, 'DD/MM/YYYY') || '"');
				htb.append_nl('}');
				htb.send('application/json', 200);
			else
				htb.send('application/json', 400);
			end if;
			
		exception
			when others then raise;
	end GetVote;
		
	procedure Replication as
		begin
			insert into users@to_cb select * from users where login not in (select login from users@to_cb);
			insert into review@to_cb select * from review where users not in (select users from review@to_cb);
			commit;
			log_pkg.LogInfo('Réplication effectuée', 'Replication');
		exception
			when others then rollback; log_pkg.LogErreur('Erreur inattendue est survenue lors de la réplication', true, 'Replication'); raise;
	end Replication;
	
	procedure PurgeCC as -- Pas testé
		begin
			delete from movie where id in (
			    select movie from review 
			    where review_date <= (sysdate - RechercheCC.date_drop) 
			    and movie in (
			    select id from movie@to_cb));
			commit;
			log_pkg.LogInfo('Purge des vieux films effectuée', 'PurgeCC');
		exception
			when others then log_pkg.LogErreur('Erreur inattendue est survenue lors de la purge des vieux films', true, 'PurgeCC'); rollback; raise;
	end PurgeCC;
    
    begin
        select INTERVAL '90' DAY (2) into date_drop from dual;
end RechercheCC;
/
show errors
