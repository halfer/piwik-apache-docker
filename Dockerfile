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

# Install basic machine dependencies
RUN apt-get update && apt-get install -y wget unzip

# Install the required PHP modules using PHP's Docker command
RUN docker-php-ext-install pdo pdo_mysql

# Grab Piwik itself
RUN mkdir -p /tmp/piwik \
	&& cd /tmp/piwik \
	&& wget https://builds.piwik.org/piwik.zip

# Minimise the size of the container image
RUN apt-get clean

# -q on unzip is for "quiet" operation
RUN cd /tmp/piwik \
    && unzip -q /tmp/piwik/piwik.zip \
	&& cp -R /tmp/piwik/piwik/* /var/www/html

# Inject settings file here
COPY config/config.ini.php /var/www/html/config/config.ini.php

# Recommended permissions for Piwik
RUN chown -R www-data:www-data /var/www/html \
	&& chmod -R 0755 /var/www/html/tmp

COPY start.sh /root/start.sh
RUN chmod u+x /root/start.sh
ENTRYPOINT ["/root/start.sh"]
