#!/bin/sh
set -eu
ip route replace 172.28.20.0/24 via 172.28.10.2
exec sleep infinity
