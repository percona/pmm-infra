#!/bin/bash
# Script to do all the waiting
waiter="$1"
name="$2"
fqdn="$3"
environment_name="$4"

if [[ $waiter == "mysql" ]]; then
  # mysql
  srv=$(echo $name | rev | cut -c3- | rev)
  while true; do
    # Get the status of the mysql_check_http check
    status=$(dig @127.0.0.1 -p 8600 ${srv}.service.consul SRV | awk "/SRV.*${fqdn}\.$/ {print \$1}")
    if [[ $status == "${srv}.service.consul." ]]; then
      echo "mysql check is passing."
      exit 0
    fi

    # If the check is not passing, wait for a short interval and try again
    echo "mysql check is not passing. Will retry in 3 seconds..."
    sleep 3
  done
elif [[ $waiter == "gr-primary" ]]; then
  # group replication primary
  while true; do
    status=$(dig +short @127.0.0.1 -p 8600 percona-server-84-gr-primary.service.consul SRV)
    if [[ $status =~ "${environment_name}.local" ]]; then
      echo "gr-primary check is passing"
      exit 0
    else
      echo "gr-primary check is not passing"
    fi
    sleep 1
  done
fi
