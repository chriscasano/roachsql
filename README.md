## This repository contains handy SQL statements for CockroachDB



<b>drop_tables.sh [db name]</b> - This script will output SQL file that contains drop table statements for a particular database name.

<b>decom_chk.sql</b> - Checks if there will be a replication policy issues if a node is decommisioned.  (i.e. Current Nodes - Defined Replication in a Zone for a set of Objects <= 0)

<b>alter_column_types</b> - How to change the data type on column when the data types are dissimilar (i.e. string to int)

<b>active_jobs.sh</b> - How many jobs are running on the cluster

<b>backup_and_check_success.sh</b> - Backup a database and monitor the process.
