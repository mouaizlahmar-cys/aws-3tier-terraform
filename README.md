# 🏗️ Production-Grade 3-Tier AWS Architecture with Modular Terraform

[![Terraform](https://img.shields.io/badge/IaC-Terraform-623CE4?logo=terraform)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-Cloud-232F3E?logo=amazon-aws)](https://aws.amazon.com/)
[![DevSecOps](https://img.shields.io/badge/Security-DevSecOps-green)](https://aws.amazon.com/security/)

This project demonstrates an enterprise-grade, 3-tier cloud infrastructure on AWS built using **Terraform**. Designed with strict **DevSecOps** best practices, it enforces the **Principle of Least Privilege**, **Zero-Trust Access (No SSH/Port 22)**, and complete isolation for database workloads.

---

## 📐 Architecture Overview

```text
               +-------------------------------------------------------+
               |                    AWS Cloud                          |
               |  Region: eu-north-1 (Stockholm)                       |
               |                                                       |
               |  +-------------------------------------------------+  |
               |  |                   VPC                           |  |
               |  |  +-------------------------------------------+  |  |
               |  |  |            Public Subnet                  |  |  |
               |  |  |  [ Internet Gateway ] <-> [ NAT Gateway ]  |  |  |
               |  |  +---------------------+---------------------+  |  |
               |  |                        |                        |  |
               |  |                        v                        |  |
               |  |  +-------------------------------------------+  |  |
               |  |  |            Private App Subnet             |  |  |
               |  |  |   [ EC2 Instance (SSM Managed) ]          |  |  |
               |  |  |   Security Group: dev-app-sg              |  |  |
               |  |  +---------------------+---------------------+  |  |
               |  |                        | (Port 5432)            |  |
               |  |                        v                        |  |
               |  |  +-------------------------------------------+  |  |
               |  |  |           Isolated DB Subnet              |  |  |
               |  |  |   [ RDS PostgreSQL 15 ]                   |  |  |
               |  |  |   Security Group: dev-db-sg               |  |  |
               |  |  +-------------------------------------------+  |  |
               |  +-------------------------------------------------+  |
               +-------------------------------------------------------+
               Key Components
VPC Module: Custom VPC (10.0.0.0/16) spanning 2 Availability Zones (eu-north-1a, eu-north-1b) with 6 subnets (Public, Private App, and Isolated Database).

Security Module: Tiered dependency Security Groups. The Database Security Group (dev-db-sg) strictly accepts inbound traffic on port 5432 only from the Application Security Group (dev-app-sg).

Compute Module: Private Amazon Linux 2023 EC2 instance without a public IP. Configured with an IAM Role for AWS Systems Manager (SSM) Session Manager to eliminate the need for SSH keys or open Port 22.

Database Module: Amazon RDS PostgreSQL 15 deployed in Isolated Subnets with storage encryption enabled and zero public access (publicly_accessible = false).

Observability: Centralized VPC Flow Logs pushing network metrics directly to Amazon CloudWatch Log Groups.

🛠️ Tech Stack & Prerequisites
Infrastructure as Code: Terraform >= 1.0

Cloud Provider: Amazon Web Services (AWS)

Database: Amazon RDS PostgreSQL 15

Security & Access: AWS SSM, IAM, Security Groups, VPC Flow Logs

CLI Tools: aws-cli, terraform, pg_isready
project structure
.
├── main.tf                   # Root module orchestrating infrastructure
├── variables.tf              # Global input variables
├── outputs.tf                # Root deployment outputs
├── terraform.tfvars.example  # Example variable assignments
├── .gitignore                # Ignored state & sensitive files
└── modules/
    ├── vpc/                  # Network configuration & subnets
    ├── security_groups/      # Tiered Security Groups & ingress/egress rules
    ├── ec2/                  # Compute instance & SSM IAM profile
    └── rds/                  # Encrypted PostgreSQL RDS instance

    ## 🚀 Deployment Guide

### 1. Clone the Repository
```bash
git clone [https://github.com/YOUR_USERNAME/aws-3tier-terraform-devsecops.git](https://github.com/YOUR_USERNAME/aws-3tier-terraform-devsecops.git)
cd aws-3tier-terraform-devsecops
2. Configure Environment Variables
cp terraform.tfvars.example terraform.tfvars
3. Initialize and Deploy Terraform
# Initialize backend and load modules
terraform init

# Review execution plan
terraform plan

# Apply infrastructure deployment
terraform apply