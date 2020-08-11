-- Node Status (should be zero)

select 'nodes draing or decommissioning' as status, count(*) as amt
from crdb_internal.gossip_nodes n,
crdb_internal.gossip_liveness l
where n.node_id = l.node_id
  and n.is_live = true
  and ( l.draining = true or l.decommissioning = true);
;

-- Ranges Unavailable (should be zero)

select 'ranges unavailable' as status, sum((metrics->>'ranges.unavailable')::DECIMAL)::INT AS amt from crdb_internal.kv_store_status;

-- Under replicated (should be zero)

SELECT sum((metrics->>'ranges.underreplicated')::DECIMAL)::INT8 AS ranges_underreplicated FROM crdb_internal.kv_store_status JOIN crdb_internal.gossip_liveness USING (node_id) WHERE NOT decommissioning;

-- Running Jobs / Schema Changes (should be zero)

select 'active jobs' as status, count(*) as amt from crdb_internal.jobs where status in ('running','paused');

-- Same versions (should be 1)

select 'versions detected' as status, count(*) as amt from (select distinct server_version from crdb_internal.gossip_nodes);

-- Storage Capacity (ratio should be < .7)

select 'storage capacity', sum((metrics->>'capacity.used')::DECIMAL)::INT8 / sum((metrics->>'capacity.available')::DECIMAL)::INT8 as ratio from crdb_internal.kv_store_status;

-- Memory Capacity
-- *** Need help on this one ***

-- CPU (should be < .5)

select 'normalized cpu', avg(cast( metrics->>'sys.cpu.combined.percent-normalized' as DECIMAL )) from crdb_internal.kv_node_status;
