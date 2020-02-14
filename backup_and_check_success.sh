#!/bin/bash
result=`cockroach sql --insecure -e "Backup Database defaultdb TO 'nodelocal:///defaultdb'"`
jobid=`echo -e $result | awk '{ print $8 }'`

### Fail if there's no job id.
if [[ -z "$jobid" ]]; then
  echo "Backup failed.  Couldn't get job id: $jobid"
  exit 1
fi

### If job succeeded, say so.  If failed or cancelled, say so.  If anything else such as paused, pending, etc, just continue.
while true;
do
  sleep 5
  status=`cockroach sql --insecure -e "select status from [show jobs] where job_id=$jobid"`
  echo $status

  if [[ $status == *"succeeded"* ]]; then
    exit 0
  elif [[ $status == *"failed"* ]]; then
    exit 1
  elif [[ $status == *"canceled"* ]]; then
    exit 1
  fi

done
