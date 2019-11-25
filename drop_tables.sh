#!/bin/bash

# This scripts outputs a drop sql table statements for a give databass.  Use with caution.  This only outputs the SQL statements, you have to run them yourself :)

export db=$1

## Create Drop Statements
echo -e "select 'DROP TABLE \x22$db\x22.' || '\x22' || TABLE_NAME || '\x22' || ';' from $db.information_schema.tables where table_type = 'BASE TABLE';" | cockroach sql --insecure --database=$db --format=raw | sed -e 's/#.*$//' -e '/^$/d' > drop_tables.sql

## Run drop statements
##cockroach sql --insecure --database=$db --echo-sql < drop_tables.sql
