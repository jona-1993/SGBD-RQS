
connect cb/oracle@192.168.0.25/orcl

-- Generate File GENRES
set feedback off
set trimspool on
set heading off
set echo off
spool AlimGenres.sql;
select distinct * from(
	with data(s) as (
	select distinct genres from movies_ext
	),
	split(s, stpos, endpos) as (
		select s, 1, instr(s, '‖') from data
		union all
		select s, endpos+1, instr(s, '‖', endpos + 1)
		from split
		where endpos > 0
	)
	,
	final(stpos, endpos, s) as (
		select stpos, case endpos when 0 then length(s) else endpos-1 end,
		substr(s, stpos, case endpos when 0 then length(s)-stpos+1 else endpos-stpos end)
		from split
	)
	select 'insert into genre values(' || regexp_substr(s, '([0-9])\w+') || ' , ''' || regexp_substr(s, '[^(․)]+$', 1) || ''');' from final 
    	where regexp_substr(s, '([0-9])\w+') is not null order by stpos
);

select 'commit;' from dual;

spool off;

set echo on
set heading on
set feedback on

disconnect

exit
