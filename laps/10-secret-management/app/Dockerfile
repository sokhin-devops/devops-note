# Same idea as client/Dockerfile — the real vault binary via a multi-stage
# COPY, not a re-download.
FROM hashicorp/vault:2.0 AS vaultbin

FROM alpine:3.20

RUN apk add --no-cache bash postgresql-client

COPY --from=vaultbin /bin/vault /usr/local/bin/vault
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
