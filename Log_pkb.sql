create or replace package body Log_pkg is

procedure LogInfo ( message  varchar2, tracking varchar2 default null) is
begin
	insert into LogInfos (tracking, who, datetime, message)
	values (tracking, user, systimestamp, message);
end LogInfo;

procedure LogInfoTjs (message  varchar2, tracking varchar2 default null ) is
pragma autonomous_transaction;
begin
	LogInfo(message, tracking);
	commit;
end LogInfoTjs;


procedure LogErreur (message     varchar2 default null, include_ora boolean  default true, tracking    varchar2 default null) is
pragma autonomous_transaction;
v_include_ora char(1);
v_sqlcode     integer;
v_sqlerrm     varchar2(512);
begin
	if include_ora then
		v_include_ora := 'Y';
		v_sqlcode     := SQLCODE;
		v_sqlerrm     := SQLERRM;
	else
		v_include_ora := 'N';
	end if;
	
	insert into LogErreurs (tracking, who, datetime, message, code, errm, error_backtrace, error_stack)
	values (
	tracking,
	user,
	systimestamp,
	message,
	v_sqlcode,
	v_sqlerrm,
	case v_include_ora when 'Y' then dbms_utility.format_error_backtrace else null end,
	case v_include_ora when 'Y' then dbms_utility.format_error_stack else null end
	);
	
	commit;
end LogErreur;

function StartLine(table_name varchar2, n integer, tracking   varchar2) return varchar2 is
	base_message varchar2(60);
	base_length  integer;
begin
	base_message := '(START) ' || table_name || '(' || case n when 0 then 'ALL' else 'LAST 000' end || ')';
	base_length  := length(base_message);
	return
	rpad(
	'(START' ||
	case when tracking is not null then ' ' || substr(tracking, 1, 60 - base_length) end ||
	') ' || table_name || ' (' || case n when 0 then 'ALL' else 'LAST ' || to_char(n, 'FM000') end || ')',
	60,
	'*'
	);
end StartLine;

function EndLine(
  table_name varchar2,
  n          integer,
  tracking   varchar2
) return varchar2
is
  base_message varchar2(60);
  base_length  integer;
begin
  base_message := '(END  ) ' || table_name;
  base_length  := length(base_message);
  return
    rpad(
        '(END  ' ||
        case when tracking is not null then ' ' || substr(tracking, 1, 60 - base_length) end ||
        ') ' || table_name,
        60,
        '*'
    );
end EndLine;

procedure DisplayLogInfos(
  n        integer default 0,
  tracking varchar2 default null
) is
  cnt integer := 1;
begin
  dbms_output.new_line;
  dbms_output.put_line(StartLine('LogInfos', n, tracking));
  for r in (
    select *
    from (
      select * from LogInfos
      where DisplayLogInfos.tracking is null
         or tracking = DisplayLogInfos.tracking
      order by datetime desc
    )
    where n = 0 or rownum <= n
    order by datetime
  ) loop
    dbms_output.put_line(rpad('LogInfos (' || to_char(cnt, 'FM000') || ') ', 60, '*'));
    dbms_output.put_line(
      'id       : ' || r.id  || CHR(10) ||
      'who      : ' || r.who || CHR(10) ||
      'datetime : ' || to_char(r.datetime, 'DD/MM/YYYY HH24:MI:SS.FF6') || CHR(10) ||
      'message  : ' || r.message
    );
    cnt := cnt + 1;
  end loop;
  dbms_output.put_line(EndLine('LogInfos', n, tracking));
end DisplayLogInfos;

procedure DisplayLogErreurs(
  n        integer default 0,
  tracking varchar2 default null
) is
  cnt integer := 1;
begin
  dbms_output.new_line;
  dbms_output.put_line(StartLine('LogErreurs', n, tracking));
  for r in (
    select *
    from (
      select * from LogErreurs
      where DisplayLogErreurs.tracking is null
         or tracking = DisplayLogErreurs.tracking
      order by datetime desc
    )
    where n = 0 or rownum <= n
    order by datetime
  ) loop
    dbms_output.put_line(rpad('LogErreurs (' || to_char(cnt, 'FM000') || ') ', 60, '*'));
    dbms_output.put_line(
      'id              : ' || r.id      || CHR(10) ||
      'who             : ' || r.who     || CHR(10) ||
      'datetime        : ' || to_char(r.datetime, 'DD/MM/YYYY HH24:MI:SS.FF6') || CHR(10) ||
      'message         : ' || r.message || CHR(10) ||
      'code            : ' || r.code    || CHR(10) ||
      'errm            : ' || r.errm    || CHR(10) ||
      'error_backtrace : ' || CHR(10) || r.error_backtrace || CHR(10) ||
      'error_stack     : ' || CHR(10) || r.error_stack
    );
    cnt := cnt + 1;
  end loop;
  dbms_output.put_line(EndLine('LogErreurs', n, tracking));
end DisplayLogErreurs;

end Log_pkg;
/
show errors
