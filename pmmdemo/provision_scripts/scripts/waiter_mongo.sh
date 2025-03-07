#!/bin/bash
# Script to do all the waiting for mongo-specific waits
waiter="$1"
name="$2"
fqdn="$3"
replica_set_name="$4"

if [[ $waiter == "mongodb" ]]; then
  # mongodb
  while true; do
	# Get the status of the mongodb check
	status=$(dig @127.0.0.1 -p 8600 ${name}.mongo-60-${replica_set_name}.service.consul SRV | awk "/SRV.*${fqdn}\.$/ {print \$1}")
	if [[ $status == "${name}.mongo-60-${replica_set_name}.service.consul." ]]; then
	  echo "mongodb check is passing."
	  exit 0
	fi
	# If the check is not passing, wait for a short interval and try again
	echo "mongodb check is not passing. Will retry in 3 seconds..."
	sleep 3
  done
elif [[ $waiter == "mongo-rs" ]]; then
  # wait for all 3 members of this mongo replica set
  while true; do
	# Get the count of members in this replica set
	cnt=$(dig +short @127.0.0.1 -p 8600 mongo-60-${replica_set_name}.service.consul SRV | wc -l)
	if [[ $cnt -eq 3 ]]; then
	  echo "3 members online"
	  exit 0
	fi
	# If the check is not passing, wait for a short interval and try again
	echo "$${cnt}/3 members online. Will retry in 3 seconds..."
	sleep 3
  done
elif [[ $service == "mongos" ]]; then
  # mongos
  while true; do
	# Get the status of the mongodb check
	status=$(dig @127.0.0.1 -p 8600 ${name}.mongos.service.consul SRV | awk "/SRV.*${fqdn}\.$/ {print \$1}")
	if [[ $status == "${name}.mongos.service.consul." ]]; then
	  echo "mongos check is passing."
	  exit 0
	fi
	# If the check is not passing, wait for a short interval and try again
	echo "mongos check is not passing. Will retry in 3 seconds..."
	sleep 3
  done
fi
