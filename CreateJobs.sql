begin
    dbms_scheduler.drop_job('job_replication');
    dbms_scheduler.create_job (
    job_name        => 'job_replication',
    job_type        => 'STORED_PROCEDURE',
    job_action      => 'RechercheCC.Replication',
    start_date      => NULL,
    end_date	    => NULL,
    --repeat_interval => 'FREQ=DAILY; BYHOUR=23', -- Tous les jours à 23h
    repeat_interval => 'FREQ=MINUTELY',
    auto_drop       =>  FALSE,
    comments        => 'Répliquer les nouveaux users et leur avis',
    enabled         => true);
    
    
    /*dbms_scheduler.drop_job('job_purgecc');
    dbms_scheduler.create_job (
    job_name        => 'job_purgecc',
    job_type        => 'STORED_PROCEDURE',
    job_action      => 'RechercheCC.PurgeCC',
    start_date      => NULL,
    end_date	    => NULL,
    --repeat_interval => 'FREQ=DAILY; BYHOUR=23', -- Tous les jours à 23h
    repeat_interval => 'FREQ=DAILY; BYDAY=1; BYHOUR=2',
    auto_drop       =>  FALSE,
    comments        => 'Purger les vieux films de CC',
    enabled         => true);*/
end;
/
