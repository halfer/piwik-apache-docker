#!/bin/sh

echo "Copying configuration..."
cp \
    /var/www/localhost/htdocs/config-volume/config.ini.php \
    /var/www/localhost/htdocs/config/config.ini.php
chown apache:apache /var/www/localhost/htdocs/config/config.ini.php

echo "Starting web server..."
# -DFOREGROUND means "don't daemonize"
/usr/sbin/httpd -DFOREGROUND
