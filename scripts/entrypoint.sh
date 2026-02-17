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
username=$(echo ${smtp_creds} | jq ".access_key" | tr -d '"')
key=$(echo ${smtp_creds} | jq ".secret_key" | tr -d '"')

echo "${relay} $username:$key"> $config_file

log "Reloading postfix credentials configuration"
postmap $config_file
chmod /etc/postfix/sasl_passwd /etc/postfix/sasl_passwd.db

# Update main.cf configuration file
postconf -e "relayhost = ${relay}"
postconf -e "smtp_sasl_auth_enable = yes"
postconf -e "smtp_sasl_password_maps = hash:$config_file"
postconf -e "smtp_sasl_security_options = noanonymous"
postconf -e "smtp_tls_security_level = encrypt"

log "Ending docker-smtp-relay"

exec "$@"