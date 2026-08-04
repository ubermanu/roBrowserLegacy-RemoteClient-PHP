FROM php:8.3-apache AS server

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

    # Game content lives in the (gitignored) data/ directory
    Alias /data   /var/www/html/data/data
    Alias /BGM    /var/www/html/data/BGM
    Alias /System /var/www/html/data/System
    Alias /AI     /var/www/html/data/AI

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

    <Directory /var/www/html/data>
        Options +FollowSymLinks -MultiViews
        AllowOverride None
        Require all granted

        <IfModule mod_rewrite.c>
            RewriteEngine On
            RewriteRule ^(.*)\.bmp$ $1\.png [NC,QSA]
        </IfModule>

        <IfModule mod_speling.c>
            CheckSpelling On
            CheckCaseOnly On
        </IfModule>
    </Directory>
</VirtualHost>
EOF

EXPOSE 80

USER www-data
