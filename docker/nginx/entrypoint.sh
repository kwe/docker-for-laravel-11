#!/usr/bin/bash

set -e
echo "PHP-FPM configuration:"
grep "listen =" /usr/local/etc/php-fpm.d/www.conf

mkdir -p /var/run/php
chown www-data:www-data /var/run/php
php-fpm &
sleep 2
ls -l /var/run/php/php-fpm.sock
nginx &

wait -n

exit $?
