# 🏢 Enterprise Full-Stack AWS DevOps Platform

An enterprise-ready, production-grade DevOps template for containerized web applications on AWS. 

This platform manages a full-stack Employee Leave Management application (**React SPA + Node.js API**) powered by **AWS RDS PostgreSQL** and deployed on **EC2 instances inside an Auto Scaling Group (ASG)** behind an **Application Load Balancer (ALB)**.

---

## 📐 Cloud Architecture Diagram

The system uses path-based routing at the load balancer level to direct traffic to the front/back container services running inside the EC2 container hosts, with secure database and state isolation:

![AWS Cloud Architecture](architecture.png)

---

## 📁 Repository Structure

```text
root/
│
├── backend/                  # Express API Backend
│   ├── Dockerfile            # Multi-stage image build definitions
│   ├── app.js                # Express app entry (Sequelize Sync)
│   ├── package.json          # Dependencies (Sequelize, PG)
│   ├── config/               # Database connection configs
│   ├── controllers/          # API logical handlers (Sequelize queries)
│   ├── middleware/           # JWT verification & role validation
│   ├── models/               # Sequelize PostgreSQL schemas
│   └── routes/               # Express routing definitions
│
├── frontend/                 # React Frontend Client
│   ├── Dockerfile            # Node build stage + Nginx static server
│   ├── nginx.conf            # Proxy routing for /api and React Router
│   ├── package.json          # Vite + React 19 dependencies
│   ├── vite.config.js        # Dev proxy configs
│   ├── public/               
│   └── src/                  
│
├── infra/                    # Modular Infrastructure (Terraform)
│   ├── environments/         
│   │   ├── dev/              # Development (single NAT gateway, db.t3.micro)
│   │   └── prod/             # Production (multi-AZ NAT, db.t3.medium HA)
│   │
│   └── modules/              # Shared infrastructure components
│       ├── vpc/              # Isolated VPC, Subnets, Gateway setups
│       ├── rds/              # RDS PostgreSQL Instance
│       ├── ec2_asg/          # Launch Template & Auto Scaling Group
│       ├── iam/              # Instance Profiles & GitHub OIDC Roles
│       └── ecr/              # Docker Registry Repositories
│
├── docker-compose.yml        # Local multi-container development platform
└── .github/
    └── workflows/            # GitHub Actions CI/CD workflows
        ├── infra.yml         # Terraform pipeline (plan, apply, destroy)
        ├── build.yml         # Docker build, Trivy scan, and ECR push
        ├── deploy.yml        # Rolling zero-downtime ASG Instance Refresh
        └── sonarqube.yml     # Code quality scanning on PRs/main branches
```

---

## 🐳 Getting Started (Local Development)

### Prerequisites
- [Docker](https://www.docker.com/) and Docker Compose installed locally.

### 1. Run the Platform
Spin up the local PostgreSQL database, backend Express API, and frontend Nginx client:
```bash
docker compose up --build
```

### 2. Access Ports
- **Frontend SPA Client**: [http://localhost:8080](http://localhost:8080)
- **Backend API Server**: [http://localhost:8000](http://localhost:8000) (Check health status at [http://localhost:8000/health](http://localhost:8000/health))
- **PostgreSQL Database**: Port `5432`

---

## 🧪 testing the Leave approval Workflow (Locally)

Because the database starts fresh and empty, you must register the accounts and assign the manager role to test the approval dashboard:

1. **Register a Manager**: Navigate to [http://localhost:8080](http://localhost:8080), sign up, and select **`manager`** as your role.
2. **Register an Employee**: Sign up another user with the default **`employee`** role.
3. **Register an Admin**: Sign up a third user with the **`admin`** role.
4. **Assign the Manager**:
   - Log in as the **admin**.
   - Navigate to the **Admin Dashboard** tab in the header.
   - Click **Edit** next to the employee account and select the **manager account** from the dropdown menu to link them. Click Save.
5. **Raise a Leave Request**:
   - Log out and log back in as the **employee**.
   - Fill out and submit a new leave request (e.g. Annual Leave).
6. **Approve the Request**:
   - Log back in as the **manager**.
   - Go to your Manager Dashboard. The employee's request will appear in your pending reviews list, allowing you to **Approve** or **Reject** it.

---

## ☁️ Terraform Deployment (`infra/`)

### Setup Prerequisites (Bootstrap)
Terraform states are stored in an S3 Bucket with locking handled by a DynamoDB table.

1. Configure your AWS credentials.
2. Edit `terraform.tfvars` in your environment directory (e.g., [`infra/environments/dev/terraform.tfvars`](infra/environments/dev/terraform.tfvars)) and update target variable details:
   - `github_repo`: Set to your repository `username/repo-name`.
   - `db_password`: Enter a secure database password.
   - `jwt_secret`: Enter a custom security key.

### Initialize & Apply
From the environment subdirectory:
```bash
# Initialize with dynamic backend values
terraform init \
  -backend-config="bucket=YOUR_UNIQUE_S3_STATE_BUCKET" \
  -backend-config="key=dev/terraform.tfstate" \
  -backend-config="region=us-east-1" \
  -backend-config="dynamodb_table=YOUR_DYNAMODB_LOCKS_TABLE"

# Deploy Resources
terraform apply
```

---

## 🛠️ CI/CD Pipelines (GitHub Actions)

Deployments are secure and OIDC-driven (no static AWS Access Keys stored in GitHub secrets).

### 1. Infrastructure Pipeline (`infra.yml`)
- **Trigger**: Manual (`workflow_dispatch`).
- **Inputs**: Environment (`dev` or `prod`) and Action (`plan`, `apply`, or `destroy`).
- **Function**: Validates infrastructure configurations and builds or tears down the target environment.

### 2. Build Pipeline (`build.yml`)
- **Trigger**: Manual (`workflow_dispatch`).
- **Inputs**: Target service (`frontend`, `backend`, or `both`) and Target environment.
- **Security Check**: Initiates a **Trivy Container Scan**. **Fails the pipeline** if any `CRITICAL` vulnerability is discovered.
- **Function**: Builds, tags (`$COMMIT_SHA` and `$ENVIRONMENT`), and pushes images to ECR.

### 3. Deploy Pipeline (`deploy.yml`)
- **Trigger**: Manual (`workflow_dispatch`).
- **Inputs**: Target service and Environment.
- **Function**: Queries AWS to find the dynamic ASG name, and launches an **ASG Instance Refresh**. This rolls out new instances running the updated containers with **zero downtime**.

### 4. Code Quality Pipeline (`sonarqube.yml`)
- **Trigger**: Automatic on Pull Requests and commits merged to `main`.
- **Function**: Runs a SonarQube Scanner code analysis check and enforces the Quality Gate.
