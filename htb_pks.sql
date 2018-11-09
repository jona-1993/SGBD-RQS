create or replace package htb as

	procedure append(line varchar2);
	procedure append_nl(line varchar2);
	procedure reset;
	procedure send(
		c clob,
		content_type varchar2 default 'text/html',
		status_code integer default 200
	);
	procedure send(
		v varchar2,
		content_type varchar2 default 'text/html',
		status_code integer default 200
	);
	procedure send(
		content_type varchar2 default 'text/html',
		status_code integer default 200
	);
end htb;
/
