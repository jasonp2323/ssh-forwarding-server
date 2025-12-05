# SSH Forwarding Server

A Terraform-based AWS infrastructure setup that deploys an EC2 instance configured as an SSH forwarding proxy for secure remote access.

## Overview

This project provisions:
- VPC with public subnet in us-east-1
- Security group restricting SSH access to a specified home IP
- Ubuntu EC2 instance with SSH tunneling enabled

## Prerequisites

- Terraform >= 1.0
- AWS CLI configured with credentials
- SSH key pair named `ssh-forwarding-server` in AWS
- Your home IP address

## Setup

1. **Initialize Terraform**:
```bash
   terraform init
```

2. **Specify your home IP** using one of these methods:

   **Option A: Command line** (one-time)
```bash
   terraform apply -var="home_ip=YOUR_HOME_IP/32"
```

**Option B: terraform.tfvars** (recommended for local development)
```bash
   echo 'home_ip = "YOUR_HOME_IP/32"' > terraform.tfvars
```
Then run `terraform apply`. Add `terraform.tfvars` to `.gitignore`.

**Option C: Environment variable**
```bash
   export TF_VAR_home_ip="YOUR_HOME_IP/32"
   terraform apply
```

3. **Get the instance IP**:
```bash
   terraform output instance_public_ip
```

## Usage

**Create SOCKS5 proxy tunnel**:
```bash
ssh -i ~/.ssh/ssh-forwarding-server.pem -D 2463 ubuntu@<instance_ip> -N
```

**Route browser traffic through proxy** (Chrome example):
```bash
chrome --proxy-server="socks5://localhost:2463"
```

## Variables

- `home_ip`: Your home IP address in CIDR notation (required, e.g., `1.2.3.4/32`)
- `instance_type`: EC2 instance type (default: `t2.micro`)
- `ubuntu_image`: Ubuntu AMI ID (default: Ubuntu 22.04 LTS for us-east-1)

## Cleanup
```bash
terraform destroy
```