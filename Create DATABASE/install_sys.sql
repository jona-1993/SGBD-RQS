connect sys/oracle@localhost/orcl as sysdba

drop user cb cascade;
drop user cc cascade;
drop role role_test;

create role role_test not identified;
grant alter session to role_test;
grant create database link to role_test;
grant create session to role_test;
grant create procedure to role_test;
grant create sequence to role_test;
grant create table to role_test;
grant create trigger to role_test;
grant create synonym to role_test;
grant create type to role_test;
grant create job to role_test;

create user cb profile default identified by oracle default tablespace users temporary tablespace temp account unlock;
alter user cb quota unlimited on users;
grant role_test to cb;

create user cc profile default identified by oracle default tablespace users temporary tablespace temp account unlock;
alter user cc quota unlimited on users;
grant role_test to cc;

create directory mydir as '/home/oracle/sgbd';
grant read,write on directory mydir to cb;

-- one-time operation
-- grant execute on sys.utl_file to public;


disconnect

exit
