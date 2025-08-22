# Project Overview - Cloud-Ready Automated LAMP (IaC + Ansible)

**What it does:** Provisions AWS infra with Terraform, configures a LAMP stack with Ansible, and deploys a PHP app.  
**Why:** Standardizes environments, eliminates manual setup, and demonstrates Cloud + DevOps skills end-to-end.

## Architecture (minimal demo)
- EC2 (Ubuntu 22.04) in default VPC
- Security Group: SSH(22), HTTP(80), HTTPS(443)
- Elastic IP attached to EC2
- MySQL on instance (RDS optional in future)

## Tech
- AWS, Terraform, Ansible, LAMP(Ubuntu, Apache2, MySQL, PHP)
- GitHub Actions (CI), UFW firewall (and Fail2ban)

## How to run (quick)
See `docs/setup-guide.md`.

## Next steps
- RDS MySQL, Let’s Encrypt HTTPS, CloudWatch agent
- Dynamic Ansible inventory from Terraform outputs
- CI deploy pipeline (staging → prod)
