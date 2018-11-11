CREATE OR REPLACE TRIGGER TriggerVote
BEFORE INSERT OR UPDATE OR DELETE ON review
FOR EACH ROW
DECLARE
    nbvotes number;
    vote number;
BEGIN
	
    if inserting then
        SELECT vote_count INTO nbvotes FROM movie WHERE id = :new.movie;
        SELECT vote_average INTO vote FROM movie WHERE id = :new.movie;
        
        UPDATE movie SET vote_count = nbvotes+1, vote_average = ((vote+:new.cote)/2) WHERE id = :new.movie;

        
    elsif deleting then
        SELECT vote_count INTO nbvotes FROM movie WHERE id = :old.movie;
        SELECT vote_average INTO vote FROM movie WHERE id = :old.movie;
        
        UPDATE movie SET vote_count = nbvotes-1, vote_average = (((vote*2)-:old.cote)) WHERE id = :old.movie;

    else
    	SELECT vote_count INTO nbvotes FROM movie WHERE id = :new.movie;
        SELECT vote_average INTO vote FROM movie WHERE id = :new.movie;
        
        UPDATE movie SET vote_average = (((vote*2)-:old.cote)) WHERE id = :old.movie;
        
        UPDATE movie SET vote_average = ((vote+:new.cote)/2) WHERE id = :new.movie;

    end if;
EXCEPTION
    WHEN OTHERS THEN log_pkg.LogErreur('Erreur de mise à jour de la table movie', true, 'TriggerVote'); raise;
END TriggerVote;
/
