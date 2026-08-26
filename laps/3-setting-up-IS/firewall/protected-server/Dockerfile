FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends nginx ufw iptables iproute2 \
    && rm -rf /var/lib/apt/lists/*

# UFW inside an unprivileged container needs three tweaks:
#  - use the legacy iptables backend (nftables is often unavailable)
#  - skip IPv6, since ip6tables usually cannot be loaded here
#  - skip UFW's sysctl tuning, because /proc/sys is read-only in Docker
RUN (update-alternatives --set iptables /usr/sbin/iptables-legacy || true) \
    && (update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy || true) \
    && sed -i 's/^IPV6=.*/IPV6=no/' /etc/default/ufw \
    && sed -i 's|^IPT_SYSCTL=|#IPT_SYSCTL=|' /etc/default/ufw

COPY html/index.html /var/www/html/index.html
COPY firewall.sh /usr/local/bin/firewall.sh
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/firewall.sh /usr/local/bin/entrypoint.sh

EXPOSE 80
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
