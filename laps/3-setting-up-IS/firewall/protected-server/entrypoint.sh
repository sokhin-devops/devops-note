#!/bin/bash
set -e

/usr/local/bin/firewall.sh

exec nginx -g "daemon off;"
