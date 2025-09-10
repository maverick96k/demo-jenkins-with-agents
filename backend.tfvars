bucket         = "terraform-eks-project-statefile-demo-setup"
key            = "prod/terraform.tfstate"
region         = "eu-north-1"
dynamodb_table = "terraform-eks-state-locks"
encrypt        = true