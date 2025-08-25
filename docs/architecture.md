# Architecture Overview

This document explains the architecture and workflow of the **CloudLAMP-Automation** project.  
The project demonstrates how to provision **cloud infrastructure** with Terraform, configure it with **Ansible**, and deploy a **PHP application** on AWS.

---

## 🏗️ High-Level Flow

1. **Terraform** provisions infrastructure:
   - AWS EC2 instance
   - Security Group
   - Elastic IP

2. **Ansible** configures the EC2 instance:
   - Installs Apache, MySQL, and PHP (LAMP stack)
   - Configures firewall and common dependencies
   - Deploys the sample PHP application

3. **Application Deployment**:
   - The PHP application (`index.php`) is copied to the Apache web directory
   - Accessible via the Elastic IP assigned by Terraform

---

## 📐 Architecture Diagram

![Architecture Diagram](architecture-diagram.png)

---

## 🔑 Key Design Decisions

- **Separation of Concerns**:  
  - Terraform handles *infrastructure provisioning*  
  - Ansible handles *configuration management*  
  - This reflects real-world DevOps practices.

- **Idempotency**:  
  - Ansible ensures re-runs are safe and do not duplicate configurations.

- **Modular Roles**:  
  - Each Ansible role (Apache, MySQL, PHP, Firewall, App) is self-contained and reusable.

- **Scalability**:  
  - Infrastructure can be extended to multi-tier (Load Balancer, RDS, Auto-scaling).

---

## 🚀 Workflow Summary

**Terraform → AWS Infra → Ansible Config → PHP App → User Browser**

This setup makes it easy to spin up a reproducible LAMP environment in the cloud, showcasing both Infrastructure as Code and Configuration Management in action.
