declare
    liste ALIMCB.list_id_movie;
begin
    SELECT 5 BULK COLLECT INTO liste FROM dual;
    ALIMCB.Ajouter(liste);
    --ALIMCB.AjouterRand(1);
exception
    when others then dbms_output.put_line(sqlerrm);
end;
