# Terraform AWS EKS Production Demo

This repository demonstrates a **professional** infrastructure-as-code setup for Amazon EKS using Terraform, along with a CI/CD pipeline using GitHub Actions.

---

## 📦 Repository Structure

```
.
├── .github
│   └── workflows
│       └── terraform.yml      # CI/CD workflow
├── environments
│   └── dev                    # dev workspace (backend, vars, etc.)
├── modules
│   ├── vpc                    # VPC, subnets, IGW, NAT GW, route tables
│   └── eks                    # EKS cluster, node groups, IAM roles
└── README.md                  # (this file)
```

---

## 🚀 Quickstart

### 1. Prerequisites

- **Terraform v1.5+**  
- **AWS CLI v2** (for `eks get-token`)  
- **kubectl**  
- An S3 bucket & DynamoDB table for Terraform state & locking  
- GitHub repo with `main` branch protected

### 2. Backend Setup

1. Create an S3 bucket and DynamoDB table:
   ```bash
   aws s3 mb s3://my-eks-prod-tfstate
   aws dynamodb create-table      --table-name my-eks-prod-tf-lock      --attribute-definitions AttributeName=LockID,AttributeType=S      --key-schema AttributeName=LockID,KeyType=HASH      --billing-mode PAY_PER_REQUEST
   ```
2. Update `environments/dev/backend.tf` with your bucket and table names.

### 3. Terraform Workflow

- **Initialize**:
  ```bash
  cd environments/dev
  terraform init
  ```
- **Plan**:
  ```bash
  terraform plan -var-file=terraform.tfvars
  ```
- **Apply** (merged to `main`, triggered manually in GitHub Actions):
  ```bash
  terraform apply -var-file=terraform.tfvars
  ```

---

## ☁️ AWS Infrastructure

### VPC Module

- VPC with configurable CIDR, DNS support  
- Public & private subnets across AZs  
- Internet Gateway & optional NAT Gateway  
- Route tables & associations

### EKS Module

- **IAM roles** for control plane and nodes  
- EKS Control Plane (version 1.29)  
- Managed Node Group

---

## 🔐 IAM & Cluster Access

### CI User (`github-ci`)

For this demo we granted the CI user **full access** to all relevant AWS services so Terraform never hits an authorization error:

```bash
# Full IAM rights
aws iam attach-user-policy --user-name github-ci   --policy-arn arn:aws:iam::aws:policy/IAMFullAccess

# Full S3 rights (state bucket, artifacts, etc.)
aws iam attach-user-policy --user-name github-ci   --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess

# Full DynamoDB rights (lock table)
aws iam attach-user-policy --user-name github-ci   --policy-arn arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess

# Full EKS rights
aws iam attach-user-policy --user-name github-ci   --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy
aws iam attach-user-policy --user-name github-ci   --policy-arn arn:aws:iam::aws:policy/AmazonEKSServicePolicy

# Worker node policies (if Terraform manages node IAM attachments)
aws iam attach-user-policy --user-name github-ci   --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly
aws iam attach-user-policy --user-name github-ci   --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy
aws iam attach-user-policy --user-name github-ci   --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy
```

> **Note:** This level of access is over-permissive and only intended for demonstration. In production, you’d scope down to least-privilege.

### Accessing the Cluster Locally

Use your **github-ci** credentials (the same IAM user that created the cluster) to avoid RBAC issues:

```bash
export AWS_ACCESS_KEY_ID=<github-ci-access-key>
export AWS_SECRET_ACCESS_KEY=<github-ci-secret>
export AWS_DEFAULT_REGION=eu-central-1

aws eks update-kubeconfig   --region eu-central-1   --name dev-eks   --alias dev-eks

kubectl config use-context dev-eks
kubectl get nodes
kubectl get pods -A
```

---

## 🛠️ GitHub Actions CI/CD Overview

- **Plan job** runs on every branch push or PR to `main`  
- **Apply job** runs only on `main` merges or manual dispatch  
- State is stored in S3 + DynamoDB  
- AWS credentials supplied via GitHub Secrets (`AWS_KEY_ID`, `AWS_SECRET`)

---

## 🧹 Cleanup

```bash
terraform destroy -var-file=terraform.tfvars
```

---

With this setup, you’ve got a **modular**, **secure**, and **automated** EKS deployment workflow ready for SRE/DevOps production use.
