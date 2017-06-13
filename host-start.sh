#!/bin/bash
#
# The approach here is to connect to the Docker subnet; the MySQL server needs to listen on the
# public IP, and must be appropriately firewalled from the web, either on a remote server or a
# development machine.
#
# We get the env vars from a build location (this contains passwords, which must not
# be committed to the repo). This is not a foolproof check, as the folder could
# still fail to contain the file required by the 'host-start.sh' script.
#
# @todo Pass host-side port in a shell parameter?

# Check we have the right number of params
if [ "$#" -ne 1 ]; then
    echo "Error: needs a parameter for the location of an environment vars file (see config/envs/local.example)"
    exit 1
fi

# Check the env vars exist
ENV_FILE=$1
if [ ! -f ${ENV_FILE} ]; then
    echo "Environment variables file not found in '${ENV_FILE}'"
    exit 1
fi

# Gets the FQ path in which this script runs
RELDIR=`dirname $0`
BASEDIR=`realpath $RELDIR`

# Get the host IP address
export DOCKER_HOSTIP=`ifconfig docker0 | grep "inet addr" | cut -d ':' -f 2 | cut -d ' ' -f 1`
echo "Connecting to database on Docker host ${DOCKER_HOSTIP}"

# Adds a host volume for Apache/PHP logs
docker run \
    --publish 127.0.0.1:8082:80 \
    --add-host=docker:${DOCKER_HOSTIP} \
    --env-file=${ENV_FILE} \
    --detach \
    --restart always \
    --volume ${BASEDIR}/log:/var/log/apache2 \
    piwik
