#!/bin/bash
set -e

TRUSTED_IP="${TRUSTED_IP:?TRUSTED_IP must be set}"

# Start from a clean INPUT chain
iptables -F INPUT

# Always allow loopback and already-established connections
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Only the trusted source may reach port 80
iptables -A INPUT -p tcp --dport 80 -s "$TRUSTED_IP" -j ACCEPT

# Everyone else is silently dropped
iptables -A INPUT -p tcp --dport 80 -j DROP

echo "Firewall rules applied (trusted source: $TRUSTED_IP):"
iptables -L INPUT -n --line-numbers
