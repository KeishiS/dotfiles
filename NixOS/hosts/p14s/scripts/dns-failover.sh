#!/usr/bin/env bash

DOMAIN=$(cat @dbDomainFile@)
UPSTREAM_DNS=$(cat @upstreamDnsFile@)
FALLBACK_IP=$(cat @dbFallbackIpFile@)
FIXED_IP=$(cat @fixedIpFile@)

HOSTS_FILE="/etc/dnsmasq-hosts/db-override.hosts"
CHECK_TIMEOUT=3
PG_PORT=5432

dns_ip=$(dig +short +time=3 +tries=1 "$DOMAIN" "@$UPSTREAM_DNS" | grep -E '^[0-9.]+$' | head -1)
use_ip=""

if [[ -n "$dns_ip" && "$dns_ip" != "$FIXED_IP" ]]; then
    use_ip="$dns_ip"
else
    use_ip="$FALLBACK_IP"
fi

current_ip=$(grep "^[0-9]" "$HOSTS_FILE" 2>/dev/null | awk '{print $1}')
if [[ "$use_ip" != "$current_ip" ]]; then
    echo "$use_ip $DOMAIN" >$HOSTS_FILE
    pkill -SIGHUP dnsmasq
    logger -t db-dns-failover "switched $DOMAIN -> $use_ip (was: ${current_ip:-none})"
fi
