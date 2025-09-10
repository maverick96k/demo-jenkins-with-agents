# Terraform Remote Backend Setup with AWS S3 and DynamoDB

This Terraform configuration creates:
- An **S3 bucket** to store the Terraform state file.
- **Versioning** enabled for state history.
- **SSE encryption** for security.
- A **DynamoDB table** for state locking to prevent concurrent changes.

---

## Prerequisites
- Terraform installed ([Download](https://developer.hashicorp.com/terraform/downloads))
- AWS CLI configured with proper credentials  
  ```bash
  aws configure
