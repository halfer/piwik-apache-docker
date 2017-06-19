Dockerised Piwik & Apache
===

Introduction
---

The [official Piwik Docker image](https://hub.docker.com/_/piwik/) was not to my liking, so I
created my own. Theirs exposes an FPM server, so it needs a proxy server container in front
of it to make it usable. Additionally, the image requires a containerised database, but I
prefer to run a MySQL installation on my Docker host, for data safety.

So, this image contains:

* A specific version of Piwik 3.x
* Apache 2
* A detected IP address to connect to a database on the host
* A host volume to write Apache/PHP log files to the host
* A host volume to store the configuration file

The Dockerfile is based on Alpine 3.5, which uses PHP 7.0. The image comes in at around
130M in size - not bad, but a bit larger than I would like. I wonder whether swapping
Apache for NginX would help here?

Usage
---

To build the image:

	./rebuild.sh

To run:

	./host-start.sh

This will expose the app just on the local network, and then Apache can be used on the
host to proxy it to the outside world.

Your "config-volume" volume should contain a `config.ini.php` file as per the [example
file](config/config.ini.php.example). You'll need to add in your database configuration
information, salt and trusted hosts.

The start script contains a few things that are useful to me, but you don't have to use it
in your own set-up. For example, I like the command to detach and run the container immediately
in the background, and I like to set up a restart policy, so that the Docker daemon
automatically starts the container when the host is rebooted. Feel free to copy this
script and tweak it, though.

Host proxy
---

This container exposes the Piwik service on a local port address over plain HTTP. If you
wish to make this available to the world, either via HTTP or HTTPS, you will need a
proxy on the host. I use Apache for this. Just install:

* mod_proxy
* mod_proxy_http

Then use something like this in your Apache config::

    <VirtualHost *:80>
        ServerName piwik.example.com

        ProxyPass / http://127.0.0.1:8082/
        ProxyPassReverse / http://127.0.0.1:8082/
    </VirtualHost>

If you want to offer a secure version, that's pretty easy too (adjust the paths to
your certificate keys to suit):

    <IfModule mod_ssl.c>
        <VirtualHost *:443>
            ServerName piwik.example.com

            ProxyPass / http://127.0.0.1:8082/
            ProxyPassReverse / http://127.0.0.1:8082/

            SSLCertificateFile /etc/letsencrypt/live/piwik.example.com/fullchain.pem
            SSLCertificateKeyFile /etc/letsencrypt/live/piwik.example.com/privkey.pem
            Include /etc/letsencrypt/options-ssl-apache.conf
        </VirtualHost>
    </IfModule>

Future improvements
---

1. There are other files in the config folder, and I wonder if there is any value in
copying these to the config volume, so any changes written to them are preserved.

2. There is no PHP console binary in this build, since Alpine 3.5 does not support it.
Perhaps 3.6 has support for this? This would be useful for archiving and other long-
running operations.

Miscellaneous notes
---

To get a shell prompt for debugging:

	docker exec -it mycontainer sh

To clean up dead images:

	docker images | grep "<none>" | grep "weeks ago" | awk '{print $3}' | xargs docker rmi

To save the container image (swap version number as appropriate):

    docker save piwik | gzip > piwik-3.0.4-image.tgz

To load the container image (swap version number as appropriate):

    docker load < /path/to/images/piwik-3.0.4-image.tgz
