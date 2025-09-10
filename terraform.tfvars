region               = "eu-north-1"
project_name         = "maverick"
vpc_cidr             = "10.0.0.0/16"
availability_zones   = ["eu-north-1a"]
public_subnet_cidrs  = ["10.0.0.0/24"]
private_subnet_cidrs = ["10.0.10.0/24"]

security_groups = {
  master = {
    description = "Allow Jenkins port and SSH"
    ingress = [
      {
        description = "SSH"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      },
      {
        description = "Custom_TCP"
        from_port   = 8080
        to_port     = 8080
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
    egress = [
      {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
  }

  agent = {
    description = "Allow SSH"
    ingress = [] # no ingress
    egress = [
      {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
  }
}

instances = {
  master = {
    ami                         = "ami-0a716d3f3b16d290c"
    instance_type               = "t3.medium"
    subnet_id                   = ""
    security_group_key          = "master"
    associate_public_ip_address = true
    root_block_device = {
      volume_size           = 30
      volume_type           = "gp3"
      delete_on_termination = true
    }
    user_data = "master.sh"
    key_name  = "new-kp"
    replicas  = 1
  }

  agent = {
    ami                         = "ami-0a716d3f3b16d290c"
    instance_type               = "t3.medium"
    subnet_id                   = ""
    security_group_key          = "agent"
    associate_public_ip_address = false
    root_block_device = {
      volume_size           = 10
      volume_type           = "gp3"
      delete_on_termination = true
    }
    user_data = "agent.sh"
    key_name  = "new-kp"
    replicas  = 1
  }
}

key_name = "new-kp"