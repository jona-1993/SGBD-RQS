#!/bin/sh

if [ -f ./AlimGenres.sql ]; then
	echo "AlimGenres.sql exists"
else
	echo "Generate AlimGenres.sql"
	/opt/sqlcl/bin/sql /nolog @GenerateGenres.sql
fi

/opt/sqlcl/bin/sql /nolog @install.sql


