# Multi-Cloud & LocalStack Terraform Architecture

Infrastructure as Code (IaC) built with **Terraform**, validated end-to-end by a **GitHub Actions** CI pipeline and tested locally with **LocalStack**, with no cloud costs involved.

The project simulates a modular, segmented network topology designed for advanced platform engineering studies and multi-cloud architecture research (AWS today, Azure and OpenStack on the roadmap).

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

The network is segmented to isolate workloads and reduce the attack surface.

**Subnets (2 total)**

| Subnet | Role |
|---|---|
| **Public (Hub)** | Ingress resources, load balancing, bastion/management access |
| **Private (Spoke)** | Application instances and backend databases, isolated from the public internet |

**Compute (4 VMs total)**

| Location | Count | Purpose |
|---|---|---|
| Public subnet | 2 | Access points, load balancers, or bastion hosts |
| Private subnet | 2 | Core application workloads or microservices |

**Supporting resources:** VPC, security groups, Application Load Balancer with listener, database, and Route 53 records (see `aws_infra/`).

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
│   ├── aws_vpc.tf               # VPC and subnets
│   ├── ec2.tf                   # Compute instances
│   ├── security_groups.tf       # Instance security groups
│   ├── aws_lb.tf                # Load balancer
│   ├── aws_lb_listener.tf       # Load balancer listener
│   ├── aws_lb_sg.tf             # Load balancer security group
│   ├── aws_db.tf                # Database
│   ├── aws_route53.tf           # DNS records
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
6. **Terraform plan**: generates the execution plan for the full topology.
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
- **Segmented subnets:** public and private tiers follow a hub-and-spoke pattern to keep application and data workloads off the public internet.

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
