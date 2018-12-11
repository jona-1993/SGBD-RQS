CREATE OR REPLACE TRIGGER TriggerVote
BEFORE INSERT OR UPDATE OR DELETE ON review
FOR EACH ROW
DECLARE
    nbvotes number;
    vote number;
    exist number;
BEGIN
	
    if inserting then
    	--select count(*) into exist from users@to_cb where :new.users = login;
        SELECT vote_count INTO nbvotes FROM movie WHERE id = :new.movie;
        SELECT vote_average INTO vote FROM movie WHERE id = :new.movie;
        
        UPDATE movie SET vote_count = nbvotes+1, vote_average = ((vote+:new.cote)/2) WHERE id = :new.movie;
        
        /*if exist > 0 then -- Le trigger sur CB s'en chargera lors de la réplication
        	UPDATE movie@to_cb SET vote_count = nbvotes+1, vote_average = ((vote+:new.cote)/2) WHERE id = :new.movie;
        end if;*/
        
    elsif deleting then
    	select count(*) into exist from users@to_cb where :old.users = login;
        SELECT vote_count INTO nbvotes FROM movie WHERE id = :old.movie;
        SELECT vote_average INTO vote FROM movie WHERE id = :old.movie;
        
        UPDATE movie SET vote_count = nbvotes-1, vote_average = (((vote*2)-:old.cote)) WHERE id = :old.movie;
        
        if exist > 0 then
        	--UPDATE movie@to_cb SET vote_count = nbvotes-1, vote_average = (((vote*2)-:old.cote)) WHERE id = :old.movie;
			delete from review@to_cb where movie = :old.movie and users = :old.users;
        end if;
    else
    	select count(*) into exist from users@to_cb where :new.users = login;
    	SELECT vote_count INTO nbvotes FROM movie WHERE id = :new.movie;
        SELECT vote_average INTO vote FROM movie WHERE id = :new.movie;
        
        UPDATE movie SET vote_average = (((vote*2)-:old.cote)) WHERE id = :old.movie;
        
        UPDATE movie SET vote_average = ((vote+:new.cote)/2) WHERE id = :new.movie;
        
        if exist > 0 then
        	/*UPDATE movie@to_cb SET vote_average = (((vote*2)-:old.cote)) WHERE id = :old.movie;
        
        	UPDATE movie@to_cb SET vote_average = ((vote+:new.cote)/2) WHERE id = :new.movie;*/
			
			update review@to_cb set movie = :new.movie, users = :new.users, cote = :new.cote, avis = :new.avis, review_date = :new.review_date
			where movie = :old.movie and users = :old.users;
        end if;
    end if;
EXCEPTION
    WHEN OTHERS THEN log_pkg.LogErreur('Erreur de mise à jour de la table movie', true, 'TriggerVote'); raise;
END TriggerVote;
