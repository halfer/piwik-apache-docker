#!/bin/bash

# Get default env vars for Apache
source /etc/apache2/envvars

# -DFOREGROUND means "don't daemonize"
/usr/sbin/apache2 -DFOREGROUND
