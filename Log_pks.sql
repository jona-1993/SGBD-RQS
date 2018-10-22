create or replace package Log_pkg is

procedure LogInfo (
	message  varchar2,
	tracking varchar2 default null
);

procedure LogInfoTjs (
	message  varchar2,
	tracking varchar2 default null
);

procedure LogErreur (
	message     varchar2 default null,
	include_ora boolean  default true,
	tracking    varchar2 default null
);

-- Displays (ordered by datetime ascending) the last n tuples (ordered by datetime descending)
-- If n = 0, it displays all tuples
-- Only those belonging to tracking unless tracking is null
procedure DisplayLogInfos(
	n        integer default 0,
	tracking varchar2 default null
);

-- Displays (ordered by datetime ascending) the last n tuples (ordered by datetime descending)
-- If n = 0, it displays all tuples
-- Only those belonging to tracking unless tracking is null
procedure DisplayLogErreurs(
	n        integer default 0,
	tracking varchar2 default null
);

end Log_pkg;
/
show errors
