#!/usr/bin/bash

set -e

php-fpm &
nginx &

wait -n
