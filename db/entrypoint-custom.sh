#!/bin/sh
set -e

export PATH="/usr/sbin:$PATH"

ip route replace 172.28.10.0/24 via 172.28.20.2

exec docker-entrypoint.sh "$@"