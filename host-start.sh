#!/bin/bash
#
# The approach here is to connect to the Docker subnet; the MySQL server needs to listen on the
# public IP, and must be appropriately firewalled from the web, either on a remote server or a
# development machine.
#
# @todo Pass an env file path to this script as a parameter
# @todo If there is no parameter passed, throw a fatal error
# @todo Pass host-side port in a shell parameter?

export DOCKER_HOSTIP=`ifconfig docker0 | grep "inet addr" | cut -d ':' -f 2 | cut -d ' ' -f 1`

echo "Connecting to database on Docker host ${DOCKER_HOSTIP}"

docker run \
    --publish 127.0.0.1:8082:80 \
    --add-host=docker:${DOCKER_HOSTIP} \
    --env-file=config/envs/local \
    --detach \
    --restart always \
    piwik
