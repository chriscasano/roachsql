# @U044WSSP4 what woud be a good SQL query to be used in the decomm process to ensure the max system and user defined range replicas matches the number of nodes -1?
# Goal - Figure out if we decommission a node, will we violate a zone configuration.

------------------------------------------
-- Displays the zones that are under replicated if a node fails (v19.2.x)
------------------------------------------
select
target,
database_name,
table_name,
index_name,
partition_name,
(select count(*) from crdb_internal.kv_node_status) as "currentNodes",
substr(regexp_extract(full_config_yaml,'num_replicas\: [0-9]+'),'\d')::int as "repFactor",
(select count(*) from crdb_internal.kv_node_status) - (substr(regexp_extract(full_config_yaml,'num_replicas\: [0-9]+'),'\d')::int) as "diff"
from crdb_internal.zones
where (select count(*) from crdb_internal.kv_node_status) - (substr(regexp_extract(full_config_yaml,'num_replicas\: [0-9]+'),'\d')::int) <= 0
;

------------------------------------------
-- Displays the zones that are under replicated if a node fails (v19.1.x)
------------------------------------------

select
zone_id,
zone_name,
(select count(*) from crdb_internal.kv_node_status) as "currentNodes",
substr(regexp_extract(config_yaml,'num_replicas\: [0-9]+'),'\d')::int as "repFactor",
(select count(*) from crdb_internal.kv_node_status) - (substr(regexp_extract(config_yaml,'num_replicas\: [0-9]+'),'\d')::int) as "diff"
from crdb_internal.zones
where (select count(*) from crdb_internal.kv_node_status) - (substr(regexp_extract(config_yaml,'num_replicas\: [0-9]+'),'\d')::int) <= 0
;


################################################################
## Output from Cockroach Cloud / Movr
################################################################
                                   target                                   |       database_name        |          table_name          | index_name | partition_name | currentNodes | repFactor | diff
+---------------------------------------------------------------------------+----------------------------+------------------------------+------------+----------------+--------------+-----------+------+
  RANGE default                                                             | NULL                       | NULL                         | NULL       | NULL           |            3 |         3 |    0
  DATABASE system                                                           | system                     | NULL                         | NULL       | NULL           |            3 |         5 |   -2
  TABLE system.public.jobs                                                  | system                     | jobs                         | NULL       | NULL           |            3 |         5 |   -2
  RANGE meta                                                                | NULL                       | NULL                         | NULL       | NULL           |            3 |         5 |   -2
  RANGE system                                                              | NULL                       | NULL                         | NULL       | NULL           |            3 |         5 |   -2
  RANGE liveness                                                            | NULL                       | NULL                         | NULL       | NULL           |            3 |         5 |   -2
  TABLE system.public.replication_constraint_stats                          | system                     | replication_constraint_stats | NULL       | NULL           |            3 |         5 |   -2
  TABLE system.public.replication_stats                                     | system                     | replication_stats            | NULL       | NULL           |            3 |         5 |   -2
  PARTITION node_3 OF INDEX managed_service_monitoring.public.nodes@primary | managed_service_monitoring | nodes                        | primary    | node_3         |            3 |         3 |    0
  PARTITION node_1 OF INDEX managed_service_monitoring.public.nodes@primary | managed_service_monitoring | nodes                        | primary    | node_1         |            3 |         3 |    0
  PARTITION node_2 OF INDEX managed_service_monitoring.public.nodes@primary | managed_service_monitoring | nodes                        | primary    | node_2         |            3 |         3 |    0
(11 rows)

Time: 43.714ms

chrisc@chrisc-test-35b.gcp-us-east4.cockroachlabs.cloud:26257/movr>





select
database_name,
table_name,
index_name,
replicas
from crdb_internal.ranges
where array_position( replicas, ( select node_id from crdb_internal.kv_node_status where address = '127.0.0.1:62314' ) ) > 0;




--

cockroach demo movr --geo-partitioned-replicas

select * from information_schema.tables where table_schema = 'crdb_internal'

## List nodes
select node_id, address, locality, address from crdb_internal.kv_node_status;

### Show nodes alive
select node_id, is_live, locality from crdb_internal.gossip_nodes;

### Total ranges
select count(*) from crdb_internal.ranges;

max system and user defined range replicas matches the number of nodes -1?

### User defined zone
select * from [SHOW ZONE CONFIGURATIONS] WHERE target not in ( 'RANGE liveness','RANGE default','DATABASE system','TABLE system.public.jobs','RANGE meta','RANGE system','TABLE system.public.replication_stats','TABLE system.public.replication_constraint_stats’);

### User defined Zones with replicas
select zone_id, subzone_id, target, range_name, database_name, table_name, index_name, partition_name, regexp_extract(full_config_yaml,'num_replicas\: [0-9]+'), full_config_yaml from crdb_internal.zones;


show create crdb_internal.kv_node_status;
           table_name          |          create_statement
+------------------------------+-------------------------------------+
  crdb_internal.kv_node_status | CREATE TABLE kv_node_status (
                               |     node_id INT8 NOT NULL,
                               |     network STRING NOT NULL,
                               |     address STRING NOT NULL,
                               |     attrs JSONB NOT NULL,
                               |     locality STRING NOT NULL,
                               |     server_version STRING NOT NULL,
                               |     go_version STRING NOT NULL,
                               |     tag STRING NOT NULL,
                               |     "time" STRING NOT NULL,
                               |     revision STRING NOT NULL,
                               |     cgo_compiler STRING NOT NULL,
                               |     platform STRING NOT NULL,
                               |     distribution STRING NOT NULL,
                               |     type STRING NOT NULL,
                               |     dependencies STRING NOT NULL,
                               |     started_at TIMESTAMP NOT NULL,
                               |     updated_at TIMESTAMP NOT NULL,
                               |     metrics JSONB NOT NULL,
                               |     args JSONB NOT NULL,
                               |     env JSONB NOT NULL,
                               |     activity JSONB NOT NU
