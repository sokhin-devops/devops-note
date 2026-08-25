FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends nginx iptables \
    && rm -rf /var/lib/apt/lists/*

COPY html/index.html /var/www/html/index.html
COPY firewall.sh /usr/local/bin/firewall.sh
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/firewall.sh /usr/local/bin/entrypoint.sh

EXPOSE 80
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
