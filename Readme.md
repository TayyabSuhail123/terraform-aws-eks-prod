# 🚀 Terraform AWS EKS Production Infrastructure

This project provides a **production-ready, modular Terraform setup** for deploying an **EKS cluster on AWS**, complete with:

- 🔹 VPC with public/private subnets
- 🔹 NAT Gateway, IGW, and route tables
- 🔹 Remote Terraform state with S3 + DynamoDB
- 🔹 Reusable modules and environment separation
- 🔹 (Coming soon) EKS cluster with managed node groups, IAM, and OIDC

---

## 📁 Project Structure

```
terraform-aws-eks-prod/
├── modules/
│   ├── vpc/                 # VPC module: subnets, NAT, routing
│   └── eks/                 # EKS module (WIP)
├── environments/
│   └── dev/                 # Dev environment with tfvars, backend, etc.
```

---

## ⚙️ Tech Stack

- 🏗 Terraform 1.x
- ☁️ AWS: VPC, EKS, IAM, NAT, S3, DynamoDB
- 🔐 Remote state + state locking
- 🔁 Reusable module structure for prod-ready infrastructure

---

## 🚀 Usage

1. Clone this repo
2. Configure your AWS credentials
3. Edit `terraform.tfvars` inside your target environment
4. Run:

```bash
terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

---

## 📦 Roadmap

- ✅ VPC Module
- ✅ Remote State Backend
- 🛠 EKS Cluster Module (in progress)
- 🔐 IAM + OIDC + Kubeconfig output
- 📊 Monitoring, logging, and GitOps (future)

---

## 📸 Screenshots (optional)

> Add screenshots of AWS Console showing subnets, NAT, IGW, etc.

---

## 🧠 Author

**Tayyab** — SRE / DevOps Engineer  
> Building clean, scalable infrastructure one module at a time.
