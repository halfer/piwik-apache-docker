#!/bin/bash

case `hostname` in
	"jon-VirtualBox")
		# For the local case, connect to localhost, and to do that we have to use the "host"
		# network option, which has security implications on an internet server. For simplicity
		# the MySQL server here can just listen on localhost.
		export DOCKER_HOSTIP=127.0.0.1
		export DOCKER_NETWORK='--net host'
		;;
	"aimee.jondh.me.uk")
		# For the remote server, connect to the Docker subnet - the MySQL server listens on the
		# public IP, but is appropriately firewalled from the web.
		export DOCKER_HOSTIP=`ip -4 addr show scope global dev eth0 | grep inet | awk '{print \$2}' | cut -d / -f 1`
		export DOCKER_NETWORK=''
		;;
esac

docker run \
	-p 127.0.0.1:9999:9999 \
	--add-host=docker:${DOCKER_HOSTIP} \
	$DOCKER_NETWORK \
	piwik
