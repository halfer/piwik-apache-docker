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
* A plugin to connect to a database using environment variables ([see here](https://github.com/halfer/piwik-database-configuration))
* A detected IP address to connect to a database on the host

The Dockerfile is based on Alpine 3.5, which uses PHP 7.0. The image comes in at around
130M in size - not bad, but a bit larger than I would like. I wonder whether swapping
Apache for NginX would help here?

Usage
---

To build the image:

	./rebuild.sh

To run:

	./host-start.sh path/to/env-vars-file

This will expose the app just on the local network, and then Apache can be used on the
host to proxy it to the outside world.

The environment variable file contains database connection information, see
[the example](config/envs/local.example). These are usually obtained from a (secret)
build repository that you maintain for your server(s).

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

Miscellaneous notes
---

To get a shell prompt for debugging:

	docker exec -it mycontainer sh

To clean up dead images:

	docker images | grep "<none>" | grep "weeks ago" | awk '{print $3}' | xargs docker rmi
