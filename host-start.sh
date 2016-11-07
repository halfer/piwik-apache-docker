#!/bin/bash
#
# The approach here is to connect to the Docker subnet; the MySQL server needs to listen on the
# public IP, and must be appropriately firewalled from the web, either on a remote server or a
# development machine.

export DOCKER_HOSTIP=`ip -4 addr show scope global dev eth0 | grep inet | awk '{print \$2}' | cut -d / -f 1`

docker run \
	-p 127.0.0.1:9999:80 \
	--add-host=docker:${DOCKER_HOSTIP} \
	piwik
