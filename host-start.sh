#!/bin/bash
#
# The approach here is to connect to the Docker subnet; the MySQL server needs to listen on the
# public IP, and must be appropriately firewalled from the web, either on a remote server or a
# development machine.
#
# @todo Pass an env file path to this script as a parameter
# @todo If there is no parameter passed, throw a fatal error
# @todo Pass host-side port in a shell parameter?

# Get the host IP address
export DOCKER_HOSTIP=`ifconfig docker0 | grep "inet addr" | cut -d ':' -f 2 | cut -d ' ' -f 1`
echo "Connecting to database on Docker host ${DOCKER_HOSTIP}"

# Get the envs var file
BASE_DIR=`dirname $0`
ENV_FILE=${BASE_DIR}/config/envs/local

# Check the env vars exist
if [ ! -f ${ENV_FILE} ]; then
    echo "Environment variables not found"
    exit 1
fi

docker run \
    --publish 127.0.0.1:8082:80 \
    --add-host=docker:${DOCKER_HOSTIP} \
    --env-file=config/envs/local \
    --detach \
    --restart always \
    piwik
