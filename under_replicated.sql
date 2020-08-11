SELECT sum((metrics->>'ranges.underreplicated')::DECIMAL)::INT8 AS ranges_underreplicated
  FROM crdb_internal.kv_store_status JOIN crdb_internal.gossip_liveness USING (node_id)
 WHERE NOT decommissioning;
