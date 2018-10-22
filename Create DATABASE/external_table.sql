create table movies_ext (
  id integer,
  title varchar2(2000 char),
  original_title varchar2(2000 char),
  release_date date,
  status varchar2(30 char),
  vote_average number(3,1),
  vote_count integer,
  runtime integer,
  certification varchar2(30 char),
  poster_path varchar2(100 char),
  budget integer,
  tagline varchar2(10000 char),
  genres varchar2(1000 char),
  directors varchar2(10000 char),
  actors varchar2(10000 char)
)
organization external (
  type oracle_loader
  default directory MYDIR
  access parameters (
    records delimited by "\n"
    characterset "AL32UTF8"
    string sizes are in characters
    fields terminated by X"E280A3"
    missing field values are null
    (
      id unsigned integer external,
      title char(2000),
      original_title char(2000),
      release_date char(10) date_format date mask "yyyy-mm-dd",
      status char(30),
      vote_average float external,
      vote_count unsigned integer external,
      runtime unsigned integer external,
      certification char(30),
      poster_path char(100),
      budget unsigned integer external,
      tagline char(10000),
      genres char(1000),
      directors char(10000),
      actors char(10000)
    )
  )
  location('movies.txt')
)
reject limit unlimited
;
