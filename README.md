Multi-Cloud & LocalStack Terraform Architecture
This repository contains Infrastructure as Code (IaC) using Terraform, with end-to-end automation via CI/CD pipelines (GitHub Actions) and local testing using LocalStack.

The project simulates a robust, modular network topology designed for advanced platform engineering studies and Multi-Cloud architectures (AWS, Azure, and OpenStack), tailored for master's level research.

🏗️ Infrastructure Architecture
The network topology is designed to isolate workloads and ensure security through subnet segmentation:

Subnets (2 Total):

Public Subnet (Hub): Dedicated to ingress resources, NAT gateways, or centralized management endpoints.

Private Subnet (Spoke): Dedicated to application instances and backend databases isolated from the public internet.

Compute Instances (4 VMs Total):

2x Instances in the Public Subnet: Acting as access points, load balancers, or bastion hosts.

2x Instances in the Private Subnet: Hosting core application workloads or microservices.

🛠️ Technologies Used
Terraform (v1.8+): Declarative infrastructure orchestration and provisioning.

AWS / LocalStack: Local emulation of AWS services (S3 for state backend, EC2/VPC for networking and compute resources).

GitHub Actions: Continuous integration and continuous delivery (CI/CD) pipeline automation.

Docker & Docker Compose: Containerized execution of the LocalStack environment for testing.

📂 Repository Structure
Plaintext
.
├── .github/
│   └── workflows/
│       └── terraform.yml       # Automated CI/CD pipeline
├── aws_infra/
│   ├── main.tf                 # Core resources (VPCs, Subnets, 4 VMs, S3)
│   ├── variables.tf            # Variable definitions
│   └── outputs.tf              # Useful infrastructure outputs
└── README.md
🔄 CI/CD Pipeline (GitHub Actions)
The pipeline executes automated validation steps on every push or pull_request to the main branch:

Repository Checkout: Clones the code into the GitHub runner.

LocalStack Initialization: Starts the local AWS environment via Docker Compose with authentication enabled.

Health Check: Waits for LocalStack to actively respond on port 4566.

S3 Backend Provisioning: Creates the simulated S3 bucket (renato-terraform-state) to manage the Terraform state.

Terraform Init & Validate: Initializes providers and validates static code syntax.

Terraform Plan: Generates the infrastructure execution plan (provisioning 2 subnets and 4 VMs).

Terraform Apply: Automatically applies infrastructure changes on the main branch.

🚀 How to Run Locally
To test the architecture locally on your machine before pushing to GitHub:

Start LocalStack:

Bash
docker compose up -d
Configure mock credentials:

Bash
export AWS_ACCESS_KEY_ID="test"
export AWS_SECRET_ACCESS_KEY="test"
export AWS_DEFAULT_REGION="us-east-1"
Initialize and Execute Terraform:

Bash
cd aws_infra
terraform init
terraform plan
