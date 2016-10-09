FROM php:7.0-fpm-alpine

EXPOSE 80

# The OpenSSL dependency and the update certs command are used to get wget
# working on an HTTPS link. We might even be able to drop the 
# update-ca-certificates command, see https://github.com/google/cadvisor/issues/1131

RUN apk add --update ca-certificates openssl \
	&& update-ca-certificates

RUN mkdir -p /tmp/piwik \
	&& cd /tmp/piwik \
	&& wget https://builds.piwik.org/piwik.zip \
	&& unzip /tmp/piwik/piwik.zip \
	&& cp -R /tmp/piwik/piwik/* /var/www/html

# @todo Inject settings file here
#COPY src/* /var/www/html

# -f means "don't daemonize"
ENTRYPOINT ["/usr/sbin/httpd", "-f"]
