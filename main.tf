terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.21.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "ssh-forwarding-vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "ssh-forwarding-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a"]
  public_subnets  = ["10.0.101.0/24"]
}

module "ssh-forwarding-sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "ssh-forwarding-sg"
  description = "Security group for SSH forwarding proxy - SSH access restricted to home IP"
  vpc_id      = module.ssh-forwarding-vpc.vpc_id

  # No general ingress rules needed
  ingress_cidr_blocks = []
  ingress_rules       = []

  # Custom ingress rules
  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH access from home IP only"
      cidr_blocks = "${var.your_ip_address}/32" # Replace with your actual home IP
    }
  ]

  # Allow all outbound traffic (needed for proxy to reach WebSocket API)
  egress_rules = ["all-all"]
}

resource "aws_instance" "ssh-forwarding-server" {
  ami                         = var.ubuntu_image
  instance_type               = var.instance_type
  associate_public_ip_address = true
  subnet_id                   = module.ssh-forwarding-vpc.public_subnets[0]
  security_groups             = [ module.ssh-forwarding-sg.security_group_id ]
  key_name                    = "ssh-forwarding-server"

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y

    # Enable SSH forwarding
    sed -i 's/#AllowAgentForwarding yes/AllowAgentForwarding yes/' /etc/ssh/sshd_config
    sed -i 's/#AllowTcpForwarding yes/AllowTcpForwarding yes/' /etc/ssh/sshd_config
    systemctl restart sshd

    # Optional: Install any tools you commonly use
    apt-get install -y htop curl wget
  EOF

}