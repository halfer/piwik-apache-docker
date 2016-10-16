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

FROM php:7.0-apache

EXPOSE 80

RUN apt-get update && apt-get install -y wget unzip

RUN mkdir -p /tmp/piwik \
	&& cd /tmp/piwik \
	&& wget https://builds.piwik.org/piwik.zip

RUN unzip /tmp/piwik/piwik.zip \
	&& cp -R /tmp/piwik/piwik/* /var/www/html

# @todo Inject settings file here
#COPY src/* /var/www/html

# -f means "don't daemonize"
ENTRYPOINT ["/usr/sbin/httpd", "-f"]
