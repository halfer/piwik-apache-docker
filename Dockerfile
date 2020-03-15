# Apache + PHP + Piwik in Docker
#
# @todo Use a multi-stage build to remove wget/unzip/openssl from production build

FROM alpine:3.11

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
RUN apk add ca-certificates

# Add dumb init to improve sig handling (stop time in CircleCI of 10sec is too slow)
RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_amd64
RUN chmod +x /usr/local/bin/dumb-init

WORKDIR /var/www/localhost/htdocs

# Remove default site
RUN rm -rf /var/www/localhost/htdocs/*

# Set up PHP to have a smaller memory limit
RUN sed -i -r 's/memory_limit = \d+M/memory_limit = 30M/g' /etc/php7/php.ini

# Grab Piwik itself (we can't unzip directly since there's no switches on `unzip`
# to remove unpack subfolders). Builds are here: https://builds.piwik.org/
RUN mkdir -p /tmp/piwik \
    && wget --no-verbose -O /tmp/piwik/piwik.zip https://builds.piwik.org/piwik-3.5.1.zip \
    && unzip -q /tmp/piwik/piwik.zip -d /tmp/piwik/ \
    && cp -R /tmp/piwik/piwik/* . \
    && rm -rf /tmp/piwik

# Prep Apache
RUN mkdir -p /run/apache2
RUN echo "ServerName localhost" > /etc/apache2/conf.d/server-name.conf
COPY config/mpm.conf /etc/apache2/conf.d/

# Port to run service on
EXPOSE 80

# Recommended permissions for Piwik
RUN chown -R apache:apache . \
    && mkdir -p tmp \
    && chmod -R 0755 tmp

COPY container-start.sh /root/container-start.sh
RUN chmod u+x /root/container-start.sh
ENTRYPOINT ["/usr/local/bin/dumb-init", "--"]
CMD ["/root/container-start.sh"]
