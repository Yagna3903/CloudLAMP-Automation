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

### See [docs/architecture-diagram.png](architecture-diagram.png)

Terraform (code) -> AWS (EC2 + SG + EIP) -> Ansible roles (LAMP) -> PHP app -> User
---

## 3) Design Principles

- **Separation of concerns**: Terraform = infra, Ansible = config.
- **Idempotency**: Re-running Ansible is safe; Terraform keeps state.
- **Modularity**: Small, focused Ansible roles; reusable for other hosts.
- **Security first**: SG restricts ports; optional UFW; SSH via key.
- **Reproducible**: One command each to *create*, *configure*, *destroy*.

---

## 4) Runbook (TL;DR)

```bash
# Terraform
cd terraform
terraform init
terraform apply -auto-approve

# Ansible
cd ../ansible
ansible-playbook -i inventories/aws/hosts.ini playbooks/setup-lamp.yml
Open the Elastic IP in your browser.

Destroy when done:

cd terraform
terraform destroy -auto-approve
