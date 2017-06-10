# Apache + PHP + Piwik in Docker

FROM alpine:3.5

# Do a system update
RUN apk update
# Piwik and Zend_Session require the session extension
# Piwik requires the php5-json extension
# Piwik requires a MySQL driver (using PDO for now)
RUN apk --update add php7-apache2 php7-pdo php7-session php7-json php7-pdo_mysql wget unzip openssl

# Refresh the SSL certs, which seem to be missing
# @todo I can't imagine there is an alternative to --no-check-certificate?
RUN wget --no-check-certificate -O /etc/ssl/cert.pem https://curl.haxx.se/ca/cacert.pem

WORKDIR /var/www/localhost/htdocs

# Remove default site
RUN rm -rf /var/www/localhost/htdocs/*

# @todo Swap the unzip/cp for a straight unzip to destination
# Grab Piwik itself
RUN mkdir -p /tmp/piwik \
	&& wget --no-verbose -O /tmp/piwik/piwik.zip https://builds.piwik.org/piwik.zip \
	&& unzip -q /tmp/piwik/piwik.zip -d /tmp/piwik/ \
	&& cp -R /tmp/piwik/piwik/* . \
	&& rm -rf /tmp/piwik

# Prep Apache
RUN mkdir -p /run/apache2
RUN echo "ServerName localhost" > /etc/apache2/conf.d/server-name.conf

# Port to run service on (added late in file to improve speed of building image should this
# need to change).
EXPOSE 80

# @todo Swap the unzip/cp for a straight unzip to destination
# Set up the database creds plugin
RUN mkdir -p /tmp/piwik-db-config
RUN wget --no-verbose -O /tmp/piwik-db-config/v0.1.zip https://github.com/halfer/piwik-database-configuration/archive/v0.1.zip \
	&& unzip -q /tmp/piwik-db-config/v0.1.zip -d /tmp/piwik-db-config \
	&& mkdir -p plugins/DatabaseConfiguration \
	&& cp /tmp/piwik-db-config/piwik-database-configuration-0.1/DatabaseConfiguration.php plugins/DatabaseConfiguration/ \
	&& rm -rf /tmp/piwik-db-config

# Inject settings file here
COPY config/config.ini.php config/config.ini.php
COPY config/global.ini.php.append /tmp/global.ini.php.append

# Append the global config to the existing file (this did not seem to be settable
# in the standard config file)
RUN cat /tmp/global.ini.php.append >> config/global.ini.php

# Recommended permissions for Piwik
RUN chown -R apache:apache . \
    && mkdir -p tmp \
	&& chmod -R 0755 tmp

# Create lock file dir
COPY container-start.sh /root/container-start.sh
RUN chmod u+x /root/container-start.sh
ENTRYPOINT ["/root/container-start.sh"]
#ENTRYPOINT ["sleep", "10000"]
