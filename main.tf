terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.8.0"
    }
  }

  backend "s3" {}
}

provider "aws" {
  region = var.region
}

module "vpc" {
  source = "git::https://github.com/maverick96k/terraform-modules.git//networking/jenkins-vpc?ref=v1.0.0"

  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs
  project_name         = var.project_name
}

resource "aws_security_group" "sg" {
  for_each    = var.security_groups
  name        = "${each.key}-sg"
  description = each.value.description
  vpc_id      = module.vpc.vpc_id

  dynamic "ingress" {
    for_each = each.value.ingress
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = each.value.egress
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  tags = {
    Name = "${var.project_name}-${each.key}"
  }
}

resource "aws_security_group_rule" "allow_ssh_from_master" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.sg["agent"].id
  source_security_group_id = aws_security_group.sg["master"].id
}

resource "aws_instance" "jenkins_master" {
  ami                         = var.instances.master.ami
  instance_type               = var.instances.master.instance_type
  subnet_id                   = module.vpc.public_subnet_ids[0]
  vpc_security_group_ids      = [aws_security_group.sg["master"].id]
  key_name                    = var.instances.master.key_name
  associate_public_ip_address = var.instances.master.associate_public_ip_address

  root_block_device {
    volume_size           = var.instances.master.root_block_device.volume_size
    volume_type           = var.instances.master.root_block_device.volume_type
    delete_on_termination = var.instances.master.root_block_device.delete_on_termination
  }

  tags = {
    Name = "${var.project_name}-master"
  }

  user_data = file(var.instances.master.user_data)
}

# Agent EC2 (multiple instances)
resource "aws_instance" "jenkins_agent" {
  count                       = lookup(var.instances.agent, "replicas", 1)
  ami                         = var.instances.agent.ami
  instance_type               = var.instances.agent.instance_type
  subnet_id                   = module.vpc.private_subnet_ids[0]
  vpc_security_group_ids      = [aws_security_group.sg["agent"].id]
  key_name                    = var.instances.agent.key_name
  associate_public_ip_address = var.instances.agent.associate_public_ip_address

  root_block_device {
    volume_size           = var.instances.agent.root_block_device.volume_size
    volume_type           = var.instances.agent.root_block_device.volume_type
    delete_on_termination = var.instances.agent.root_block_device.delete_on_termination
  }

  tags = {
    Name = "${var.project_name}-agent-${count.index}"
  }

  user_data = file(var.instances.agent.user_data)
}