connect cb/oracle@localhost/orcl

@DropCBCC.sql

@CreateCBCC.sql

@AlimBase.sql

@AlimGenres.sql

@Log_pks.sql

@Log_pkb.sql

@AlimCB_pks.sql

@AlimCB_pkb.sql


disconnect


connect cc/oracle@localhost/orcl

@DropCBCC.sql

@CreateCBCC.sql

@AlimBase.sql

@AlimGenres.sql

@Log_pks.sql

@Log_pkb.sql

@htb_pks.sql

@htb_pkb.sql

@RechercheCC_pks.sql

@RechercheCC_pkb.sql

drop database link to_cb;
create database link to_cb connect to cb identified by oracle using 'localhost/orcl';

disconnect

exit
