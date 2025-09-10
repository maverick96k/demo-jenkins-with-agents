variable "region" {
  description = "AWS region"
  type        = string
}

variable "project_name" {
  description = "Name prefix for all Jenkins resources"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for Jenkins VPC"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones for subnets"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "security_groups" {
  type = map(object({
    description = string
    ingress     = list(object({
      description = string
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
    }))
    egress = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
    }))
  }))
  description = "Map of security groups and their rules"
}

variable "instances" {
  type = map(object({
    ami                         : string
    instance_type               : string
    subnet_id                   : string
    security_group_key          : string   # reference key in aws_security_group.sg map
    associate_public_ip_address : bool
    root_block_device           : object({
      volume_size           : number
      volume_type           : string
      delete_on_termination : bool
    })
    user_data : string
    key_name  : string
    replicas  : optional(number)  # default 1 if not specified
  }))
  description = "Map of EC2 instances to create"
}

variable "key_name" {
  type        = string
  description = "Key pair name for EC2 instances"
}