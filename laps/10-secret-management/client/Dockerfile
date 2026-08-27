# Reuses the real vault binary straight from HashiCorp's own image (its
# Dockerfile confirms it lands at /bin/vault) instead of hand-downloading
# a release zip and guessing at the current version/checksum.
FROM hashicorp/vault:2.0 AS vaultbin

FROM alpine:3.20

RUN apk add --no-cache bash curl jq postgresql-client

COPY --from=vaultbin /bin/vault /usr/local/bin/vault

CMD ["sleep", "infinity"]
