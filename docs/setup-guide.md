# CloudLAMP Setup Guide (Using AWS)

This guide explains, step by step, how to provision an Ubuntu EC2 instance on AWS with **Terraform**, then configure a **LAMP** stack (Linux, Apache, MySQL, PHP) with **Ansible**, and finally verify it in a browser. It’s written so a first-time reader can reproduce the project.

---

## What You’ll Build (Architecture)

- **AWS EC2 (Ubuntu 22.04)** in a public subnet  
- **Security Group** allowing SSH (22), HTTP (80), HTTPS (443)  
- **Static public IP (Elastic IP)** attached to EC2  
- **Apache + PHP + MySQL (local server)** installed by Ansible  
- **Sample PHP app** with a simple “visit counter” backed by MySQL

> In a later enhancement you can move MySQL to **AWS RDS** and add HTTPS (Let’s Encrypt), but this guide covers the minimal working deployment.

---

## Prerequisites

- **AWS account** with a non-root **IAM user** that has programmatic access (Access Key ID + Secret Access Key).  
- **Billing alarm** (budget) configured in AWS to avoid surprises.  
- **AWS CLI** installed and configured on your controller machine (NixOS VM).  
  - Test: `aws sts get-caller-identity` should return your Account and Arn.  
- **Terraform ≥ 1.6**, **Ansible ≥ 2.14** installed locally.  
- **SSH key pair** named `lamp-aws-key` in AWS *and* present locally at `~/.ssh/lamp-aws-key` (PEM format).  
  - Local key permissions: `chmod 600 ~/.ssh/lamp-aws-key`.

> **Region choice**: I have used `us-east-1` which is widely used and cost-effective. Make sure the same region is used in AWS CLI and Terraform.

---

## Costs & Cleanup (Important)

Running an EC2 instance and an Elastic IP incurs charges while they’re **allocated**.  
- **When you finish a demo**, destroy the infra: `terraform destroy -auto-approve`.  
- Double-check in the AWS Console that the **instance and Elastic IP** are gone.

---

## Quickstart Flow

1) **Provision infra with Terraform** → get the EC2 public IP.  
2) **Point Ansible inventory** at that IP.  
3) **Run Ansible** to install LAMP + deploy demo app.  
4) **Verify in a browser**.  
5) **Capture screenshots** and commit docs.  
6) **Destroy** when done (to avoid charges).

---

## Step 1 - Configure AWS CLI (one-time)

Open a terminal on your Controller Machine (In my case **controller VM** (NixOS)) and run:

```bash
aws configure
# Paste your IAM user's Access Key ID
# Paste your IAM user's Secret Access Key
# Default region name: us-east-1
# Default output format: json
```

**Test credentials:**
```bash
aws sts get-caller-identity
```
Expected JSON includes your `Account` and `Arn`. If you see a signature error, re-run `aws configure` and paste the keys carefully.

> **Security**: Never commit `~/.aws/credentials`. If leaked, **delete the key** in IAM.

---

## Step 2 - Provision Infrastructure with Terraform

From the repository root:

```bash
cd terraform
terraform init                 # downloads AWS provider
terraform fmt -recursive       # keeps code formatted
terraform validate             # sanity checks
terraform plan -out plan.tfplan
terraform apply -auto-approve plan.tfplan
```

**What this does**
- Creates a Security Group for ports **22/80/443**  
- Launches **Ubuntu 22.04** EC2 instance  
- Attaches an **Elastic IP** (static public IP)

**Output**  
Terraform prints outputs at the end. **Copy the `ec2_public_ip`** - you’ll need this for Ansible next.

If `init`/`apply` fails, check:
- AWS creds configured (`aws sts get-caller-identity` works)
- Region matches your CLI config
- Your IAM user has permissions (AdministratorAccess is fine for learning)

---

## Step 3 - Configure Ansible Inventory

Edit `ansible/inventories/aws/hosts.ini` and replace the placeholder with the **actual** public IP from Terraform:

```ini
[lamp]
<EC2_PUBLIC_IP> ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/lamp-aws-key
```

> **Note**: On Ubuntu EC2 images the default SSH user is `ubuntu`.

**Optional sanity check:** ensure your key is readable:
```bash
chmod 600 ~/.ssh/lamp-aws-key
ssh -i ~/.ssh/lamp-aws-key ubuntu@<EC2_PUBLIC_IP>
exit
```

---

## Step 4 - Run Ansible (LAMP install + app deploy)

From repo root:

```bash
cd ansible

# 1) Check connectivity
ansible -i inventories/aws/hosts.ini -m ping lamp
# Expected Output: "pong"

# 2) Run the full setup
ansible-playbook -i inventories/aws/hosts.ini playbooks/setup-lamp.yml
```

**What the playbook does (roles):**
- `common`: apt update + base tools  
- `firewall`: installs and enables UFW; opens SSH/HTTP  
- `apache`: installs Apache, enables `mod_rewrite`, deploys a vhost  
- `php`: installs PHP and common extensions  
- `mysql`: installs MySQL server locally, creates `demoapp` DB and `demo_user`  
- `app`: deploys `index.php` to `/var/www/html/app`

If any task fails, copy the error and try to fix as per **Troubleshooting** below.

---

## Step 5 - Verify

**Browser (from your host machine):**
- Visit: `http://<EC2_PUBLIC_IP>`  
- You should see **“LAMP Demo”** and a **visit counter** increasing on refresh.

**On the EC2 instance (optional deeper checks)**
Requires you to SSH in your EC2 instance then run:
```bash
# Apache & MySQL services
sudo systemctl status apache2
sudo systemctl status mysql

# PHP version
php -v

# Apache error log
sudo tail -n 50 /var/log/apache2/error.log
```

---

## Step 6 - Tear Down (avoid charges)

When you’re done practicing or after a demo:

```bash
cd terraform
terraform destroy -auto-approve
```

Confirm in the AWS console that:
- EC2 instance is **terminated**
- Elastic IP is **released**

---

## Troubleshooting (common issues)

**1) `UNREACHABLE!` during Ansible ping**  
- Security Group must allow **SSH (22)** from your public IP  
- File permissions: `chmod 600 ~/.ssh/lamp-aws-key`  
- Inventory user must be `ubuntu` for Ubuntu images  
- Instance must be in **running** state and use the key name `lamp-aws-key`

**2) SSH timeout**  
- You’re on a network blocking outbound 22  
- Wrong public IP (confirm `terraform output` or EC2 console)  
- UFW misconfig on instance (our role allows OpenSSH)

**3) Apache default page instead of the app**  
- Ensure `/var/www/html/app/index.php` exists and is readable  
- Confirm vhost deployed to `/etc/apache2/sites-available/000-default.conf`  
- Reload Apache: `sudo systemctl reload apache2`

**4) “DB Connection failed” in the page**  
- MySQL service running? `sudo systemctl status mysql`  
- The role creates DB `demoapp` and user `demo_user` with password `demo_pass`  
- PHP `mysqli` extension installed (our role installs it)

**5) Terraform errors**  
- Credentials/region mismatched → re-run `aws configure`  
- Provider download/network issues → re-run `terraform init`  
- “Non fast-forward” on git pushes → pull/rebase from `main` first

---

## Security Notes (minimum best practices)

- DO NOT commit secrets (`~/.aws/credentials`, PEM keys).  
- Restrict SSH ingress to **your IP** in `terraform/variables.tf` (`ssh_ingress_cidr`).  
- Enable MFA on AWS root; use IAM for day-to-day.  

---

## TL;DR Command Block

If you already met the prerequisites, here’s the shortest path:

```bash
# Terraform
cd terraform
terraform init
terraform fmt -recursive
terraform validate
terraform plan -out plan.tfplan
terraform apply -auto-approve plan.tfplan
# Copy the ec2_public_ip from outputs

# Ansible
cd ../ansible
ansible -i inventories/aws/hosts.ini -m ping lamp
ansible-playbook -i inventories/aws/hosts.ini playbooks/setup-lamp.yml

# Verify
# Open http://<EC2_PUBLIC_IP> in your browser

# Teardown when done
cd ../terraform
terraform destroy -auto-approve
```
