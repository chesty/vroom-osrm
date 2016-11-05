#!/bin/sh

sed -ie 's#root /var/www/html;#root /vroom-frontend;#' /etc/nginx/sites-available/default
ln -sf /dev/stdout /var/log/nginx/access.log
ln -sf /dev/stderr /var/log/nginx/error.log
nginx -c /etc/nginx/nginx.conf -g "daemon off;"

