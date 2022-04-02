#!/usr/bin/env bash

set -eu

envsubst '${PROXY_PASS},${NAXSI_CONFIG_VERSION}' < /app/config/conf.d/server.conf.template > /app/config/conf.d/server.conf
mkdir -p /etc/nginx/conf.d
cp /app/config/conf.d/server.conf /etc/nginx/conf.d/server.conf
cp /app/config/nginx.conf /etc/nginx/nginx.conf

exec "$@"
