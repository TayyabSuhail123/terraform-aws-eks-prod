# EKS-on-AWS Demo — Production-Style VPC + Terraform

> **Purpose**  
> A lightweight, reproducible lab that spins up a real Amazon EKS cluster and supporting VPC in ~10 minutes.  
> Perfect for interviews, hands-on learning, or SRE run‑books.

---

## ✨ Stack Overview

| Layer        | Tech           | What it does                                 |
|--------------|---------------|----------------------------------------------|
| **IaC**      | Terraform 1.7 | Declarative VPC + EKS + IAM modules           |
| **Networking** | Custom VPC, public & private subnets, NAT GW | Isolated cluster networking |
| **Kubernetes** | AWS EKS 1.29 | Managed control‑plane, 2 × `t3.micro` worker nodes |
| **State**      | S3 backend + DynamoDB lock table | Safe, team‑ready remote state |

> **Demo mode:** worker nodes live in **public** subnets (cheapest, no NAT charges).  
> Flip `subnet_ids = var.private_subnet_ids` + add a NAT per AZ for production.

---

## 🏗 Deploy (dev environment)

```bash
cd environments/dev
terraform init
terraform apply      # ~10 min, ~USD 0.10/hr until you destroy
```

☕ Wait until Terraform prints **Apply complete**.

```bash
aws eks --region eu-central-1 update-kubeconfig --name dev-eks
kubectl get nodes
```

You should now see two **Ready** nodes.

---

## 🔄 Teardown (stop the bill!)

```bash
cd environments/dev
terraform destroy
```

Everything—NAT EIP, node‑group, control‑plane—gone.

---

## 📂 Repo Structure

```
├── modules/
│   ├── vpc/          # CIDR, subnets, IGW, optional NAT
│   └── eks/          # IAM roles, cluster, node group
├── environments/
│   └── dev/          # Thin wrappers + tfvars
└── README.md
```

---

## 😓 Troubleshooting Cheatsheet

| Symptom | Fix |
|---------|-----|
| `NodeCreationFailure` → _“Instances failed to join the cluster”_ | 1️⃣ Check **aws‑auth** ConfigMap has the node IAM role.<br>2️⃣ Ensure worker subnets have outbound Internet.<br>&nbsp;&nbsp;• Public subnet → IGW route, public IP.<br>&nbsp;&nbsp;• Private subnet → NAT GW in **same AZ**.<br>3️⃣ Verify node SG allows egress 0.0.0.0/0. |
| `kubectl` times out | Run `aws eks update-kubeconfig` again — credentials expire after ~12 h. |
| Need SSH | Add `remote_access { ec2_ssh_key = "my-key" }` to the node group **or** use SSM. |

---

## 💰 Cost Notes

| Resource                | Demo               | Prod                     |
|-------------------------|--------------------|--------------------------|
| EKS control‑plane       | \$0.10 / h         | same                     |
| EC2 nodes (`t3.micro`×2)| \$0.02 / h         | scale as needed          |
| NAT GW                  | \$0 (public nodes) | \$0.045 / h each         |
| S3 + DynamoDB           | ≈ \$0.01 / month   | negligible               |

Destroy when finished to avoid charges.

---

## 📜 License

use freely, PRs welcome.
