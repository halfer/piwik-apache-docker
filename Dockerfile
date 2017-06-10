# Apache + PHP + Piwik in Docker

FROM alpine:3.5

# Do a system update
RUN apk update
RUN apk --update add apache2 php7 php7-pdo wget unzip openssl

# Refresh the SSL certs, which seem to be missing
# @todo I can't imagine there is an alternative to --no-check-certificate?
RUN wget --no-check-certificate -O /etc/ssl/cert.pem https://curl.haxx.se/ca/cacert.pem

WORKDIR /var/www

# Grab Piwik itself
# -q on unzip is for "quiet" operation
RUN mkdir -p /tmp/piwik \
	&& cd /tmp/piwik \
	&& wget --no-verbose https://builds.piwik.org/piwik.zip \
	&& unzip -q /tmp/piwik/piwik.zip \
	&& cp -R /tmp/piwik/piwik/* . \
	&& rm -rf /tmp/piwik

# Prep Apache
RUN mkdir -p /run/apache2
RUN echo "ServerName localhost" > /etc/apache2/conf.d/server-name.conf

# Port to run service on (added late in file to improve speed of building image should this
# need to change).
EXPOSE 80

# Set up the database creds plugin
RUN mkdir -p /tmp/piwik-db-config \
	&& wget --no-verbose -O /tmp/piwik-db-config https://github.com/halfer/piwik-database-configuration/archive/v0.1.zip \
	&& unzip -q /tmp/piwik-db-config/v0.1.zip \
	&& mkdir plugins/DatabaseConfiguration \
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
	&& chmod -R 0755 tmp

# Create lock file dir
COPY container-start.sh /root/container-start.sh
RUN chmod u+x /root/container-start.sh
#ENTRYPOINT ["/root/container-start.sh"]
ENTRYPOINT ["sleep", "10000"]
