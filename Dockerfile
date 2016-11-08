# Apache + PHP + Piwik
#
# The original intention of this Docker file was to use Alpine, but getting everything running
# happily on that seems to be a fair bit of work. Instead one perhaps could use this
# https://github.com/nimmis/docker-alpine-apache-php7 but it is not well-used, so caution may
# be necessary.
#
# Alternatively I could look at the official Piwik image (https://github.com/piwik/docker-piwik)
# but this needs an NginX front end and MySQL in separate containers, so I think swapping to
# a more substantial base would be best for now.
#
# I tried the official PHP image, but this produces contains of around 550M, way too high. Ubuntu
# seems to be better, producing a container of around 360M.

FROM ubuntu

# Needed to turn off errors when installing PHP
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
	&& apt-get install -y apache2 php php-pdo php-mysql wget unzip \
	&& apt-get clean autoclean \
	&& apt-get autoremove -y \
	&& rm -rf /var/lib/{apt,dpkg,cache,log}/ \
	&& rm -rf /var/cache \
	&& rm -rf /var/log/*

# Grab Piwik itself
# -q on unzip is for "quiet" operation
RUN mkdir -p /tmp/piwik \
	&& cd /tmp/piwik \
	&& wget --no-verbose https://builds.piwik.org/piwik.zip \
	&& unzip -q /tmp/piwik/piwik.zip \
	&& cp -R /tmp/piwik/piwik/* /var/www/html \
	&& rm -rf /tmp/piwik

# Port to run service on (added late in file to improve speed of building image should this
# need to change).
EXPOSE 80

# Inject settings file here
COPY config/config.ini.php /var/www/html/config/config.ini.php

# Recommended permissions for Piwik
RUN chown -R www-data:www-data /var/www/html \
	&& chmod -R 0755 /var/www/html/tmp

COPY container-start.sh /root/container-start.sh
RUN chmod u+x /root/container-start.sh
ENTRYPOINT ["/root/container-start.sh"]
