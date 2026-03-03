# Docker image for Postgres SMTP Relay with Amazon SES and ECS

> A lightweight **Amazon Linux**-based Docker image running **Postfix** as an SMTP relay and forwarding outbound email through **Amazon SES**. This image is set to be deploy in ECS cluster. I am using SASL authentication and TLS encryption.


## Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- An **Amazon Web Services** account with:
  - A verified sending domain or email address
  - SMTP credentials (username + password)
- The following files present before building:
  - `scripts/entrypoint.sh` — container entrypoint script
  - `sources/sender_canonical` — Postfix sender rewriting rules

## Image Details

| Property | Value |
|----------------|---------------------------------------------|
| Base Image     | amazonlinux:latest |
| MTA            | Postfix |
| Auth           | SASL |
| TLS            | Enforced |
| Exposed Port   | 25 |
| Maintainer     | jimmy@archnops.com |

## Exposed Ports

| Port | Protocol | Description                         |
|------|----------|-------------------------------------|
| 25 | TCP      | SMTP - ⚠️ for internal relay use only ⚠️ |

## 🔒 Security Considerations

- **Restrict access** to port `25` — bind only to private resources, not public IPs
- **SMTP Credentials** are stored in **AWS Secret Manager** and injected in `sources/sasl_passwd` through the `entrypoint.sh` script
- **Rotate SES SMTP credentials** regularly via the AWS IAM console


## Testing

Send a test email from inside the running container:

```bash
docker exec -it smtp-relay bash

echo "Test from SMTP relay" | mailx -s "Test Subject" -r sender@yourdomain.com contact@example.com
```

Check Postfix logs:

```bash
docker exec -it smtp-relay tail -f /var/log/postfix.log
```



## Tags

| Tag      | Description           |
|----------|-----------------------|
| `latest` | Latest stable release |
| `x.y.z`  | Specific version      |



## License

This project is licensed under the [MIT License](LICENSE).