#!/bin/sh
set -eu
iptables -F FORWARD
iptables -P FORWARD DROP
iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -s 172.28.10.0/24 -d 172.28.20.10 -p tcp --dport 80 -m conntrack --ctstate NEW -j ACCEPT
iptables -L FORWARD -n -v
exec sleep infinity
