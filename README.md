# Cloud-Ready Automated LAMP (IaC + Ansible)

[![CI](https://github.com/Yagna3903/CloudLAMP-Automation/actions/workflows/ci.yml/badge.svg)](https://github.com/Yagna3903/CloudLAmp-Automation/actions)

**One-click infra + app deploy:**  
This project provisions **AWS** infrastructure with **Terraform**, configures a **LAMP stack** (Linux, Apache, MySQL, PHP) using **Ansible**, and deploys a sample PHP web app.  

Built as a **Cloud + DevOps showcase project** - demonstrates cloud provisioning, automated configuration management, and CI/CD integration.

---

## Quickstart (5 min demo)

```bash
1. Clone repo
git clone https://github.com/Yagna3903/CloudLAMP-Automation.git
cd CloudLAMP-Automation

2. Init Terraform + provision infra (creates EC2 + Security Group + EIP)
cd terraform
terraform init
terraform apply -auto-approve

3. Run Ansible playbook (installs Apache, PHP, MySQL, app code)
cd ../ansible
ansible-playbook -i inventory.ini playbook.yml

4. Visit your Elastic IP in browser
```
## Full guide → docs/setup-guide.md
