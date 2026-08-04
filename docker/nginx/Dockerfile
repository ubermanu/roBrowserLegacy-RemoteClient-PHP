FROM php:8.3-fpm-alpine

LABEL org.opencontainers.image.description="Creates a environment to serve PHP files for the Remote Client API."

WORKDIR /var/www/html

RUN apk add --no-cache nginx supervisor

# gd and its image library dependencies
RUN apk add --no-cache libpng libjpeg-turbo freetype && \
  apk add --no-cache --virtual .build-deps libpng-dev libjpeg-turbo-dev freetype-dev && \
  docker-php-ext-configure gd --with-jpeg --with-freetype && \
  docker-php-ext-install -j"$(nproc)" gd && \
  apk del .build-deps

RUN <<'EOF' cat > /etc/nginx/http.d/ro-mime-types.conf
types {
    application/ro-action   act;
    application/ro-sprite   spr;
    application/ro-palette  pal;
    application/ro-ground   gnd;
    application/ro-altitude gat;
    application/ro-world    rsw;
    application/ro-model    rsm;
}
EOF

RUN <<'EOF' cat > /etc/nginx/http.d/default.conf
server {
    listen 8080 default_server;
    listen [::]:8080 default_server;
    server_name _;

    absolute_redirect off;

    root /var/www/html/public;
    index index.php;

    add_header 'Access-Control-Allow-Origin' '*';
    add_header 'Access-Control-Allow-Headers' 'X-Application';
    error_page 404 /index.php;

    # BMP images are stored as PNG once extracted from the GRFs
    rewrite ^(.*)\.bmp$ $1.png last;

    gzip on;
    gzip_comp_level 5;
    gzip_min_length 256;
    gzip_vary on;
    gzip_proxied any;
    gzip_types
        application/ro-action
        application/ro-sprite
        application/ro-palette
        application/ro-ground
        application/ro-altitude
        application/ro-world
        application/ro-model
        text/plain
        application/xml;

    # Game content lives in the client/ mount. Files already on disk are served
    # statically; anything else falls back to index.php which extracts them
    # from the GRF archives.
    location /data/ {
        alias /var/www/html/client/data/;
        try_files $uri /index.php$is_args$args;
    }

    location /BGM/ {
        alias /var/www/html/client/BGM/;
        try_files $uri /index.php$is_args$args;
    }

    location /System/ {
        alias /var/www/html/client/System/;
        try_files $uri /index.php$is_args$args;
    }

    location /AI/ {
        alias /var/www/html/client/AI/;
        try_files $uri /index.php$is_args$args;
    }

    location / {
        try_files $uri $uri/ /index.php$is_args$args;
    }

    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_index index.php;
        include fastcgi_params;

        # index.php only serves files when REDIRECT_STATUS is 404 (an Apache
        # ErrorDocument artifact); fastcgi_params hardcodes it to 200.
        fastcgi_param REDIRECT_STATUS 404;
    }

    location ~ /\. {
        log_not_found off;
        deny all;
    }
}
EOF

# The supervisor package ships this file as 0600, and cat keeps that mode
RUN chmod 644 /etc/supervisord.conf

RUN <<'EOF' cat > /etc/supervisord.conf
[supervisord]
nodaemon=true
logfile=/dev/stdout
logfile_maxbytes=0
pidfile=/tmp/supervisord.pid

[program:php-fpm]
command=php-fpm -F
autorestart=true
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0

[program:nginx]
command=nginx -g 'daemon off;'
autorestart=true
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
EOF

COPY bootstrap.php configs.php ./
COPY src/ ./src/
COPY public/ ./public/
COPY bin/ ./bin/

# client/ is a mount point, so its ownership comes from the host
# var/ subdirs are created at runtime, so it only needs to be writable
RUN mkdir -p var client && \
  chown www-data:www-data var

# nginx runs as www-data instead of its own user, so it needs the pid directory,
# the logs and the request body buffers under /var/lib/nginx
RUN mkdir -p /run/nginx && \
  chown -R www-data:www-data /run/nginx /var/log/nginx /var/lib/nginx

EXPOSE 8080

USER www-data

CMD ["supervisord", "-c", "/etc/supervisord.conf"]
