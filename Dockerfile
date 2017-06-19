# Apache + PHP + Piwik in Docker

FROM alpine:3.5

# Do a system update
RUN apk update
# Piwik and Zend_Session require the session extension
# Piwik requires the php5-json extension
# Piwik requires a MySQL driver (using PDO for now)
# Piwik outputs error "Call to undefined function Piwik\ctype_alnum"
# Extensions required in system check: zlib, iconv, mbstring, dom, openssl, gd
RUN apk --update add \
    php7-apache2 php7-pdo php7-session php7-json php7-pdo_mysql \
    php7-ctype php7-zlib php7-iconv php7-mbstring php7-dom php7-openssl php7-gd \
    wget unzip openssl

# Refresh the SSL certs, which seem to be missing
# @todo I can't imagine there is an alternative to --no-check-certificate?
RUN wget --no-check-certificate -O /etc/ssl/cert.pem https://curl.haxx.se/ca/cacert.pem

WORKDIR /var/www/localhost/htdocs

# Remove default site
RUN rm -rf /var/www/localhost/htdocs/*

# Set up PHP to have a smaller memory limit
RUN sed -i -r 's/memory_limit = \d+M/memory_limit = 30M/g' /etc/php7/php.ini

# Grab Piwik itself (we can't unzip directly since there's no switches on `unzip`
# to remove unpack subfolders). Builds are here: https://builds.piwik.org/
RUN mkdir -p /tmp/piwik \
    && wget --no-verbose -O /tmp/piwik/piwik.zip https://builds.piwik.org/piwik-3.0.4.zip \
    && unzip -q /tmp/piwik/piwik.zip -d /tmp/piwik/ \
    && cp -R /tmp/piwik/piwik/* . \
    && rm -rf /tmp/piwik

# Prep Apache
RUN mkdir -p /run/apache2
RUN echo "ServerName localhost" > /etc/apache2/conf.d/server-name.conf

# Port to run service on
EXPOSE 80

# Useful for debugging
#RUN apk --update add nano

# Recommended permissions for Piwik
RUN chown -R apache:apache . \
    && mkdir -p tmp \
    && chmod -R 0755 tmp

COPY container-start.sh /root/container-start.sh
RUN chmod u+x /root/container-start.sh
ENTRYPOINT ["/root/container-start.sh"]

# Useful for debugging
#ENTRYPOINT ["sleep", "10000"]
