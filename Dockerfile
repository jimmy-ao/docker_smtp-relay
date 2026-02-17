# SMTP Relay Dockerfile

# Define the base image
FROM amazonlinux:latest

# Update package list and install required packages
RUN yum update -y 
RUN yum install -y jq python3 iputils
RUN yum clean all
RUN rm -rf /var/lib/apt/lists/*

# Create directory for scripts and copy entrypoint script    
RUN mkdir -p /scripts
COPY ./scripts/entrypoint.sh /scripts/
RUN chmod +x /scripts/entrypoint.sh

ENTRYPOINT [ "/scripts/entrypoint.sh" ]

# Install and configure Postfix
RUN yum install -y postfix cyrus-sasl-plain mailx

COPY sources/sender_canonical /etc/postfix
RUN postmap /etc/postfix/sender_canonical

RUN postconf -e "relayhost = [email-smtp.eu-north-1.amazonaws.com]:587"
RUN postconf -e "smtp_sasl_auth_enable = yes"
RUN postconf -e "smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd"
RUN postconf -e "smtp_sasl_security_options = noanonymous"
RUN postconf -e "smtp_tls_security_level = encrypt"

# Open SMTP port
EXPOSE 25
 
### Start app
CMD ["postfix", "start-fg"]
RUN  postfix start

LABEL maintainer="jimmy@archnops.com"