#!/bin/sh
set -eu
ip route replace 172.28.10.0/24 via 172.28.20.2
exec nginx -g "daemon off;"
