# Jenkins on AWS with Master and Agents (Terraform)

This repository provisions a **Jenkins master** and **multiple Jenkins agent EC2 instances** on AWS using Terraform.  
It uses a reusable VPC module and follows infrastructure-as-code best practices.

---

## 📦 Features

- **Remote S3 backend** for Terraform state
- **Custom VPC** (via [terraform-modules repo](https://github.com/maverick96k/terraform-modules)) with public and private subnets
- **Security groups** for Jenkins master and agents with controlled ingress/egress
- **Jenkins Master EC2** instance with user data bootstrap
- **Jenkins Agent EC2** instances (scalable using `replicas`)
- SSH access control between master and agents

---

## 📂 Project Structure

jenkins-terraform/  
├── main.tf  
├── variables.tf  
├── terraform.tfvars  
├── outputs.tf  
├── backend.tfvars  
└── README.md  

---

## 🚀 Usage

### 1️⃣ Backend Configuration

Edit `backend.tfvars` with your S3 bucket details:

```hcl
bucket         = "my-jenkins-terraform-state"
key            = "jenkins/terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "terraform-locks"
