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
relay="[email-smtp.eu-north-1.amazonaws.com]:587"
username=$(echo ${smtp_creds} | jq -r '.["SMTP user name"]')
key=$(echo ${smtp_creds} | jq '.["SMTP password"]')

echo "${relay} $username:$key" > $config_file

postmap /etc/postfix/sasl_passwd
chmod 600 /etc/postfix/sasl_passwd /etc/postfix/sasl_passwd.db

log "Ending docker-smtp-relay"

exec "$@"