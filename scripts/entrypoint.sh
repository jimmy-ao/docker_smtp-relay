#!/bin/bash
set -e

log_file="/tmp/docker-smtp-relay.log"
config_file="/etc/postfix/sasl_passwd"

# Function to log with timestamp
log() {
    echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] $1" >> "$log_file"
}

log "Copying credential informations in file"

# Append configuration with smtp token
username=$(echo ${applications_smtp_key} | jq ".username" | tr -d '"')
key=$(echo ${applications_smtp_key} | jq ".key" | tr -d '"')
echo $'\t'$username':'$key >> $config_file

log "Reloading postfix credentials configuration"
postmap $config_file

log "Ending docker-smtp-relay"

exec "$@"