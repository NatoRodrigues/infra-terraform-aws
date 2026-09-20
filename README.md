# Multi-Cloud & LocalStack Terraform Architecture

Infrastructure as Code (IaC) built with **Terraform**, validated end-to-end by a **GitHub Actions** CI pipeline and tested locally with **LocalStack**, with no cloud costs involved.

The project simulates a modular, load-balanced network topology designed for advanced platform engineering studies and multi-cloud architecture research (AWS today, Azure and OpenStack on the roadmap).

![Terraform](https://img.shields.io/badge/Terraform-1.8%2B-844FBA?logo=terraform&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/CI-GitHub%20Actions-2088FF?logo=githubactions&logoColor=white)
![LocalStack](https://img.shields.io/badge/AWS%20emulation-LocalStack-4D0DB5)
![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?logo=docker&logoColor=white)

---

## Table of Contents

- [Architecture](#-architecture)
- [Technologies](#-technologies)
- [Repository Structure](#-repository-structure)
- [CI Pipeline](#-ci-pipeline-github-actions)
- [Running Locally](#-running-locally)
- [Remote State & Locking](#-remote-state--locking)
- [Design Decisions](#-design-decisions)
- [Roadmap](#-roadmap)

---

## 🏗️ Architecture

Traffic reaches the workloads through an **Application Load Balancer (ALB)**. The application instances live in **private subnets**, and access is controlled by dedicated **security groups** at both the load balancer and instance level.

| Layer | Resources |
|---|---|
| **Network** | 1 VPC with **2 private subnets** |
| **Compute** | **4 VMs (EC2)** distributed across the 2 private subnets |
| **Load balancing** | **Application Load Balancer** with a listener forwarding traffic to the 4 VMs |
| **Security** | Security group for the **load balancers** (`aws_lb_sg.tf`) and security groups for the **instances/VPC** (`security_groups.tf`) |
| **DNS** | **Route 53** records, created **conditionally** through a toggle variable |
| **Data** | Database (`aws_db.tf`) |

### Security model

- The **load balancer security group** defines what can reach the ALB (listener ports).
- The **instance security groups** only accept traffic from the load balancer, so the VMs are never exposed directly.
- Instances sit in private subnets, isolated from direct internet access.

### Conditional Route 53

DNS resources are created only when enabled, using Terraform conditional expressions (`count`) driven by an input variable. This lets the same code run in LocalStack (where DNS may be skipped) and in environments where a real hosted zone exists.

---

## 🛠️ Technologies

| Tool | Purpose |
|---|---|
| **Terraform (v1.8+)** | Declarative provisioning and orchestration |
| **AWS / LocalStack** | Local emulation of AWS services (S3, DynamoDB, EC2, VPC, ELB, Route 53) |
| **GitHub Actions** | CI automation (validate, plan, integration-test apply) |
| **Docker & Docker Compose** | Containerized LocalStack for local and CI environments |

---

## 📂 Repository Structure

```
.
├── .github/
│   └── workflows/
│       └── terraform.yml        # CI pipeline
├── aws_infra/
│   ├── backend.tf               # S3 remote state + DynamoDB lock
│   ├── providers.tf             # AWS provider (LocalStack endpoints)
│   ├── variables.tf             # Input variable definitions
│   ├── terraform.tfvars         # Variable values
│   ├── aws_vpc.tf               # VPC and 2 private subnets
│   ├── ec2.tf                   # 4 compute instances
│   ├── security_groups.tf       # Instance / VPC security groups
│   ├── aws_lb.tf                # Application Load Balancer
│   ├── aws_lb_listener.tf       # ALB listener
│   ├── aws_lb_sg.tf             # Load balancer security group
│   ├── aws_db.tf                # Database
│   ├── aws_route53.tf           # DNS records (conditional)
│   ├── dynamodb.tf              # DynamoDB resources
│   └── .terraform.lock.hcl      # Provider version lock
├── compose.yml                  # LocalStack container definition
├── .gitignore
└── README.md
```

---

## 🔄 CI Pipeline (GitHub Actions)

The pipeline runs on every `push` and `pull_request` to `main`. It executes entirely inside an ephemeral GitHub runner against a throwaway LocalStack instance, so **no real cloud resources are created**.

1. **Checkout**: clones the repository into the runner.
2. **Start LocalStack**: brings up the local AWS emulator with Docker Compose.
3. **Readiness check**: polls LocalStack's `/_localstack/init/ready` endpoint until initialization completes.
4. **Backend provisioning**: creates the S3 bucket (`renato-terraform-state`) and the DynamoDB lock table (`terraform-locks`).
5. **Terraform init & validate**: initializes the backend and providers, then validates the configuration.
6. **Terraform plan**: generates the execution plan (VPC, 2 private subnets, 4 VMs, ALB, security groups, and conditional Route 53).
7. **Terraform apply**: applies the plan on pushes to `main`, acting as an integration test of the code.

> **Note:** because LocalStack is destroyed when the job ends, `apply` here validates that the code works; it does not deliver infrastructure. A real CD stage (AWS + OIDC + manual approval) is on the [roadmap](#-roadmap).

---

## 🚀 Running Locally

**Prerequisites:** Docker, Docker Compose, Terraform >= 1.8, AWS CLI, and a LocalStack auth token.

**1. Start LocalStack**

```bash
export LOCALSTACK_AUTH_TOKEN="<your-token>"
docker compose up -d
```

**2. Configure mock credentials**

```bash
export AWS_ACCESS_KEY_ID="mock_access_key"
export AWS_SECRET_ACCESS_KEY="mock_secret_key"
export AWS_DEFAULT_REGION="us-east-1"
```

**3. Create the remote state backend**

```bash
aws --endpoint-url=http://localhost:4566 s3 mb s3://renato-terraform-state

aws --endpoint-url=http://localhost:4566 dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

**4. Run Terraform**

```bash
cd aws_infra
terraform init
terraform validate
terraform plan
terraform apply
```

**5. Tear down**

```bash
terraform destroy
docker compose down -v
```

---

## 🔐 Remote State & Locking

Terraform state is stored in an S3 bucket, with a DynamoDB table (`terraform-locks`) providing state locking to prevent concurrent modifications. Both are created before `terraform init`, since the backend must exist before Terraform can use it.

---

## 🧠 Design Decisions

- **LocalStack in CI:** fast, free, and reproducible feedback on every commit, with no risk to a real account.
- **Named Docker volume for LocalStack:** avoids bind-mount permission issues (LocalStack's DynamoDB binary failing to execute) in CI runners.
- **Committed `terraform.tfvars`:** all values target LocalStack and contain no secrets, which keeps the pipeline reproducible for anyone who clones the repository.
- **Private subnets behind an ALB:** workloads are never exposed directly; the load balancer is the single entry point.
- **Separate security groups for LB and instances:** least-privilege rules, where instances only trust traffic coming from the load balancer.
- **Conditional Route 53:** DNS is optional, so the same code works with or without a hosted zone.

---

## 🗺️ Roadmap

- [ ] Separate `ci.yml` (LocalStack) and `cd.yml` (real AWS with OIDC and manual approval)
- [ ] `terraform fmt -check` and static analysis (tflint, checkov) in CI
- [ ] Toggle between LocalStack and real AWS endpoints via a variable
- [ ] Azure module
- [ ] OpenStack module
- [ ] Reusable Terraform modules per cloud provider

---

## 📄 License

This project is intended for educational and research purposes.
