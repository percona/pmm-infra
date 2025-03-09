#!/bin/bash
# Script to do all the waiting
waiter="$1"
name="$2"
fqdn="$3"
environment_name="$4"

if [[ $waiter == "process-exporter" ]]; then
  # process-exporter
  while true; do
    # Get the status of the process-exporter_check_http check
    status=$(dig @127.0.0.1 -p 8600 ${name}.process-exporter.service.consul SRV | awk "/SRV.*${fqdn}\.$/ {print \$1}")

    if [[ $status == "${name}.process-exporter.service.consul." ]]; then
    echo "process-exporter check is passing."
    exit 0
    fi

    # If the check is not passing, wait for a short interval and try again
    echo "process-exporter check is not passing. Will retry in 3 seconds..."
    sleep 3
  done
elif [[ $waiter == "proxysql" ]] || [[ $waiter == "valkey-exporter" ]] || [[ $waiter == "haproxy-exporter" ]]; then
  # Generic
  while true; do
    # Get the status of the check
    status=$(dig @127.0.0.1 -p 8600 ${waiter}.service.consul SRV | awk "/SRV.*${name}.${environment_name}.local.$/ {print \$1}")

    if [[ $status == "${waiter}.service.consul." ]]; then
      echo "${waiter} check is passing."
      exit 0
    fi

    # If the check is not passing, wait for a short interval and try again
    echo "${waiter} check is not passing. Will retry in 3 seconds..."
    sleep 3
  done
elif [[ $waiter == "readyz" ]] ; then
  # PMM readyz
  while true; do
    # Check for DNS :facepalm:
    dnsstatus=$(dig pmm-server.${environment_name}.local A | awk '/A.*10.*$/ {print $1}')

    if [[ $dnsstatus == "pmm-server.${environment_name}.local." ]]; then
    echo "PMMreadyz_check_http DNS check is passing."

    # Get the status of the PMMreadyz_check_http check
    status=$(dig @127.0.0.1 -p 8600 pmmreadyz.service.consul SRV | awk "/SRV.*bastion.${environment_name}.local.$/ {print \$1}")

    if [[ $status == "pmmreadyz.service.consul." ]]; then
        echo "PMMreadyz_check_http check is passing."
        exit 0
    fi
    else
    echo "PMMreadyz_check_http DNS check is not passing."
    fi
    # If the check is not passing, wait for a short interval and try again
    echo "PMMreadyz_check_http check is not passing. Will retry in 1 second..."
    sleep 1
  done
fi