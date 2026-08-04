FROM php:8.3-apache

LABEL org.opencontainers.image.description="Creates a environment to serve PHP files for the Remote Client API."

WORKDIR /var/www/html

USER root

RUN apt-get update -y -qq && \
  a2enmod rewrite && \
  a2enmod headers

# gd and its image library dependencies
RUN apt-get install -y -qq libpng-dev libjpeg62-turbo-dev libfreetype6-dev && \
  docker-php-ext-configure gd --with-jpeg --with-freetype && \
  docker-php-ext-install -j"$(nproc)" gd && \
  rm -rf /var/lib/apt/lists/*

RUN rm -f /etc/apache2/sites-available/000-default.conf

RUN <<'EOF' cat >> /etc/apache2/sites-available/000-default.conf
<VirtualHost *:80>
    DocumentRoot /var/www/html/public
    ErrorDocument 404 /index.php

    # Game content comes from the read-only client/ directory
    Alias /data   /var/www/html/client/data
    Alias /BGM    /var/www/html/client/BGM
    Alias /System /var/www/html/client/System
    Alias /AI     /var/www/html/client/AI

    <IfModule mod_rewrite.c>
        RewriteEngine On

        # BMP images are stored as PNG once extracted from the GRFs
        RewriteRule ^/((?:data|BGM)/.*)\.bmp$ /$1.png [NC]

        # ... and files already extracted into var/ win over the client's own copy.
        # Substituting a filesystem path directly, since an Alias would no longer
        # be applied at this point of the request.
        RewriteCond /var/www/html/var/extracted/$1 -f
        RewriteRule ^/((?:data|BGM)/.*)$ /var/www/html/var/extracted/$1 [L]
    </IfModule>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined

    <IfModule mod_headers.c>
        Header set Access-Control-Allow-Origin "*"
        Header set Access-Control-Allow-Headers "X-Application"
    </IfModule>
    <Directory /var/www/html/public>
        Options +FollowSymLinks -MultiViews
        AllowOverride None
        Require all granted
    </Directory>

    <Directory /var/www/html/var/extracted>
        Options +FollowSymLinks -MultiViews
        AllowOverride None
        Require all granted
    </Directory>

    <Directory /var/www/html/client>
        Options +FollowSymLinks -MultiViews
        AllowOverride None
        Require all granted

        # Client files are named as Windows left them, so a request often only
        # differs from the file on disk in case. mod_speling would look like the
        # fix, but it answers with a redirect to the canonical server name,
        # which behind a reverse proxy is an internal hostname the browser
        # cannot resolve. The 404 goes to index.php instead, which resolves the
        # real name in-process (see CLIENT_CASE_INSENSITIVE).
    </Directory>

    <IfModule mod_gzip.c>
        mod_gzip_on Yes
        mod_gzip_dechunk Yes
        mod_gzip_item_include file \.(act|spr|pal|txt|xml|lua|lub|gnd|gat|rsw|rsm)$
    </IfModule>

    <IfModule mod_mime.c>
        AddType application/ro-action          .act
        AddType application/ro-sprite          .spr
        AddType application/ro-palette         .pal
        AddType application/ro-ground          .gnd
        AddType application/ro-altitude        .gat
        AddType application/ro-world           .rsw
        AddType application/ro-model           .rsm
    </IfModule>

    <IfModule mod_deflate.c>
        AddOutputFilterByType DEFLATE \
            application/ro-action \
            application/ro-sprite \
            application/ro-palette \
            application/ro-ground \
            application/ro-altitude \
            application/ro-world \
            application/ro-model \
            text/plain \
            application/xml
    </IfModule>

</VirtualHost>
EOF

COPY bootstrap.php configs.php ./
COPY src/ ./src/
COPY public/ ./public/
COPY bin/ ./bin/

# client/ is a mount point, so its ownership comes from the host
# var/ subdirs are created at runtime, so it only needs to be writable
RUN mkdir -p var client && \
  chown www-data:www-data var

EXPOSE 80

USER www-data
