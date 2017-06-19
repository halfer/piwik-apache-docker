#!/bin/bash
#
# The approach here is to connect to the Docker subnet; the MySQL server needs to listen on the
# public IP, and must be appropriately firewalled from the web, either on a remote server or a
# development machine.
#
# The configuration file "config.ini.php" should be set up in the shared volume "config-volume"
# which will then be copied into position when the container starts. This means that,
# currently, changes to the config will not be reflected immediately. They can either be
# also edited into config/config.ini.php in the running container, or the container should
# be restarted.
#
# @todo Pass host-side port in a shell parameter?

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
    --detach \
    --restart always \
    --volume ${BASEDIR}/log:/var/log/apache2 \
    --volume ${BASEDIR}/config-volume:/var/www/localhost/htdocs/config-volume \
    piwik
