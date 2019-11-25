-- This scirpt is useful if you want to adjust column types (i.e. String to Int)

-- create test table
create table test( id string, mycol int, primary key(id));

-- insert data
insert into test values ('1', 1), ('2', 2) ,('3',3);

-- You’re probably trying to do this…unfortunately this won’t work today
-- See here: https://www.cockroachlabs.com/docs/stable/alter-type.html
alter table test alter mycol set data type decimal(10,2);

-- Instead do this if you don’t want to preserve data
Set sql_safe_updates =false;
alter table test rename column mycol to mycol_old, add column mycol decimal, drop column mycol_old;
Set sql_safe_updates =true;

-- Do this if you want to preserve data
-- Create new column, populate it, validate it, drop old column, rename new column, retest, show the new create statement
alter table test add column mycol_new decimal;
update test set mycol_new = mycol;
select * from test;
alter table test drop column mycol;
alter table test rename mycol_new to mycol;
select * from test;
show create test;
