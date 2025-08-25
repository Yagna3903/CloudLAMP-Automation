# CloudLAMP-Automation - Architecture

This document explains how the project provisions **AWS infrastructure** with **Terraform**, configures it with **Ansible**, and serves a **PHP app** (LAMP stack).

---

## 1) High-Level Flow

Terraform -> AWS resources -> Ansible configuration -> PHP app -> User browser

1. **Terraform**
   - Files: `terraform/main.tf`, `variables.tf`, `provider.tf`, `plan.tfplan`
   - Provisions:
     - EC2 instance (Ubuntu)
     - Security Group (HTTP/80, SSH/22 from your IP)
     - Elastic IP (EIP) and association

2. **Ansible**
   - Inventory: `ansible/inventories/aws/hosts.ini`
   - Playbook: `ansible/playbooks/setup-lamp.yml`
   - Roles:
     - `common` – packages, updates, users
     - `firewall` – ufw rules (optional if using only SG)
     - `apache` – installs/enables Apache, vhost config
     - `mysql` – installs MySQL server, secures basics
     - `php` – installs PHP + extensions
     - `app` – deploys sample `index.php`

3. **Application**
   - App deployed to `/var/www/html/`
   - Reached via the **Elastic IP** in your browser

---

## 2) Diagram

### See [docs/architecture-diagram.png](docs/architecture-diagram.drawio).

