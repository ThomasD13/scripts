#!/bin/bash

#This will write "ttyS0" to /sys/module/kgdboc/parameters/kgdboc to enable kdb
USERNAME=root
HOSTS="172.16.1.142" # Use space as delimeter for multiple hosts "host1 host2 host3"
SCRIPT=$1
if [ -z "$SCRIPT" ]
then
	echo "Usage: executeRemoteScript.sh scriptToExecute.sh"
fi
for HOSTNAME in ${HOSTS}; do
	echo "Execute script ${SCRIPT} on Machine ${USERNAME}@${HOSTNAME}"
	ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -l ${USERNAME} ${HOSTNAME} 'bash -s' < "${SCRIPT}"
	echo "Finished"
done
