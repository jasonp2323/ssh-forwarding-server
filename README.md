# SSH Forwarding Server

A Terraform-based AWS infrastructure setup that deploys an EC2 instance configured as an SSH forwarding proxy for secure remote access.

## Overview

This project provisions:
- VPC with public subnet in `us-east-1`
- Security group restricting SSH access to a specified IP address
- Ubuntu EC2 instance with SSH agent and TCP forwarding enabled

## Prerequisites

- Terraform >= 1.0
- AWS CLI configured with credentials
- An SSH key pair named `ssh-forwarding-server` created in AWS (EC2 → Key Pairs)
- Your current public IP address (`curl ifconfig.me`)

## Setup

1. **Initialize Terraform**:
   ```bash
   terraform init
   ```

2. **Specify your IP address** using one of these methods:

   **Option A: Command line** (one-time)
   ```bash
   terraform apply -var="your_ip_address=1.2.3.4"
   ```

   **Option B: terraform.tfvars** (recommended for repeated use)
   ```
   your_ip_address = "1.2.3.4"
   ```
   Then run `terraform apply`. `terraform.tfvars` is gitignored and will not be committed.

   **Option C: Environment variable**
   ```bash
   export TF_VAR_your_ip_address="1.2.3.4"
   terraform apply
   ```

3. **Get the instance IP**:
   ```bash
   terraform output instance_public_ip
   ```

## Usage

**Create a SOCKS5 proxy tunnel**:
```bash
ssh -i ~/.ssh/ssh-forwarding-server.pem -D 2463 ubuntu@<instance_ip> -N
```

**Route browser traffic through the proxy** (Chrome example):
```bash
chrome --proxy-server="socks5://localhost:2463"
```

## Variables

| Name | Description | Default |
|------|-------------|---------|
| `your_ip_address` | Your public IP address (without CIDR suffix) | required |
| `instance_type` | EC2 instance type | `t2.micro` |
| `ubuntu_image` | Ubuntu AMI ID (us-east-1) | Ubuntu 22.04 LTS |

## Security

- SSH access is restricted to your IP address only (port 22)
- Password authentication and root login are disabled on the instance
- All outbound traffic is permitted (required for proxy functionality)

## Cleanup

```bash
terraform destroy
```
