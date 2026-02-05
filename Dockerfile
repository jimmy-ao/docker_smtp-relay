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
RUN yum install -y postfix mailx
COPY /sources/main.cf /etc/postfix/
COPY /sources/sasl_passwd /etc/postfix/
COPY sources/sender_canonical /etc/postfix
RUN postmap /etc/postfix/sasl_passwd
RUN postmap /etc/postfix/sender_canonical

# Handle file rights
RUN chown root:root /etc/postfix/sasl_passwd /etc/postfix/sasl_passwd.db
RUN chmod 0600 /etc/postfix/sasl_passwd /etc/postfix/sasl_passwd.db
RUN chown -R root:root /etc/postfix/
RUN chmod -R 655 /etc/postfix/

# Open SMTP port
EXPOSE 25
EXPOSE 53
 
### Start app
CMD ["postfix", "start-fg"]
RUN  postfix start

LABEL maintainer="jimmy@archnops.com"