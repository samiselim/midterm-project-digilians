# Session Recap

## [2026-06-14T11:34:45Z] Consolidated Labs and Assignments Execution
- **Task Accomplished**: Consolidated all labs and assignments in the DevOps Diploma from Session 1 (DevOps Mindset) to Session 9 (Terraform) into a single unified folder structure under `all-labs/`.
- **Files Created/Modified**:
  - Initialized permanent agent memory at [MEMORY.md](file:///Users/sami/Desktop/DevOps%20Diploma/MEMORY.md).
  - Provisioned the complete target folder structure `all-labs/` with chronologically prefixed folders for all labs and assignments.
  - Copied original instructions (`lab.md` or `assignment.md`) into each lab and assignment folder.
  - Authored comprehensive solution markdown files (`solution.md` or `assignment_solution.md`) detailing VSM parameters, Kanban boards, Post-Mortems, GPG setups, Git commands logs, Linux/Docker permissions, networking tests, AWS designs (complete with Mermaid charts), and Terraform.
  - Implemented working code/configuration blueprints (Dockerfiles, `docker-compose.yml` configs, Python/Bash scripts, and complete raw Terraform HCL modules and root configurations).
- **Next Steps**: Handover to the user for repository publishing, AWS console deployments, and review.

## [2026-06-14T14:48:00+03:00] Completed AWS HA, GitHub Actions, and Terraform Solutions
- **Task Accomplished**: Finished all remaining solution files for Topic 7 (AWS HA), Topic 8 (GitHub Actions), and Topic 9 (Terraform), completing the portfolio consolidation project.
- **Files Created/Modified**:
  - **Topic 7 (AWS HA & Scaling)**: Authored `solution.md` configurations for ASG/ALB setup, CloudFront edge caching, Route 53 DNS apex Alias records, safe cleanup sequence, and the final HA architecture review with Mermaid diagrams.
  - **Topic 8 (GitHub Actions)**: Created custom labs for basic pipelines (`basics.yml`), secrets management (`secrets.yml`), and multi-platform parallel environments execution (`matrix-artifacts.yml`), migrating from GitLab CI.
  - **Topic 9 (Terraform)**: Authored module code for VPC, EC2, and ALB. Created root orchestration files (`main.tf`, `variables.tf`, `outputs.tf`), remote state configs (`backend.tf`), dynamic server templates, and modular dependency solutions.
  - **Project Tracking**: Checked off all checkpoints in `task.md` and finalized `walkthrough.md`.

## [2026-06-14T18:10:00+03:00] Expanded Terraform Variables Presentation
- **Task Accomplished**: Updated the Terraform presentation files (`presentation.md` and `presentation.html`) under `09-Terraform/` to include comprehensive explanations of Terraform variable types, declarations, and referencing syntax.
- **Files Created/Modified**:
  - **`09-Terraform/presentation.md`**: Updated the Pillar 3 and 4 agenda slide tracks, inserted Slide 13 (Primitives & Collections types), Slide 14 (Maps, Objects, & Tuples), and Slide 15 (Declarations & Referencing syntax), and shifted subsequent slides 13-20 to slides 16-23.
  - **`09-Terraform/presentation.html`**: Updated the Reveal.js HTML slide decks, updating Slide 2's agenda summary table, page index counts globally, inserting slides 13, 14, and 15, and shifting slide identifiers and page counters dynamically.
  - **`09-Terraform/Modules , Variables and Loops.pdf`**: Compiled the updated HTML presentation deck to PDF using Google Chrome in headless print mode.

## [2026-06-16T04:15:00+03:00] Enhanced Midterm Exam Question Bank
- **Task Accomplished**: Modified the midterm exam question bank (`midterm_questions_bank.md`) to align all MCQs with the concepts and configurations taught in the diploma labs.
- **Files Created/Modified**:
  - **`midterm_questions_bank.md`**:
    - Question 2: Replaced filesystem paths (`~/.gitconfig` / `/etc/gitconfig`) with Git configuration command levels (`--global`, `--system`, `--local`).
    - Question 60: Replaced theoretical Copy-on-Write storage driver question with a practical Docker command question (`docker build -t` build and tag).
    - Question 70: Replaced Git tag internal objects distinction with annotated tag creation flags (`-a` / `-m`).
    - Question 77: Updated CIDR blocks sizes choices to valid AWS VPC prefix bounds (`/16` vs `/24` vs `/28`).
    - **Formatting Update**: Reformatted the entire document of 130 questions, removing the separate `*Answer: [Letter]*` lines and formatting the correct options in bold directly inside the choices.

## [2026-06-16T04:20:00+03:00] Shuffled Midterm Question Bank & Category Removal
- **Task Accomplished**: Shuffled all questions inside `midterm_questions_bank.md` randomly and cleaned up all category headers and separators, leaving a unified renumbered list.
- **Files Created/Modified**:
  - **`midterm_questions_bank.md`**: Removed Table of Contents, subheadings like "## 1. Git & GitHub Basics...", and horizontal dividers. Renumbered the 130 shuffled questions sequentially from 1 to 130.
  - **Solid Circle Formatting**: Relocated the solid circle symbol `●` to the end of the choice line inside the bold tags for each correct choice.

## [2026-06-16T04:22:00+03:00] Triangle Indicator & PDF Compilation
- **Task Accomplished**: Replaced all solid circle `●` correct option indicators with solid triangle `▲` indicators in `midterm_questions_bank.md`, and compiled the document to a styled PDF using headless Google Chrome.
- **Files Created/Modified**:
  - **`midterm_questions_bank.md`**: Replaced all occurrences of `●**` with `▲**` at the end of correct options.
  - **`midterm_questions_bank.pdf`**: Generated a PDF document at the root of the workspace representing the styled midterm questions bank.
  - **`09-Terraform/generate_pdf.py`**: Cleaned up the helper Python script.

## [2026-06-16T04:28:00+03:00] Question 5 Deletion and Replacement
- **Task Accomplished**: Replaced the deleted Question 5 in `midterm_questions_bank.md` with a new question regarding AWS NAT Gateways to preserve the total question count at 130, and rebuilt the final styled PDF.
- **Files Created/Modified**:
  - **`midterm_questions_bank.md`**: Added a new Question 5 testing knowledge of AWS NAT Gateways for private subnet internet connectivity.
  - **`midterm_questions_bank.pdf`**: Regenerated and compiled the PDF to reflect the updated set of questions.

## [2026-06-17T03:35:00+03:00] Completed Enterprise AWS DevOps Platform with PostgreSQL & EC2 Compute
- **Task Accomplished**: Built the full-stack containerized platform, migrated backend to Sequelize/Postgres, defined modular Terraform multi-environment infrastructure, and built 4 OIDC CI/CD pipelines.
- **Files Created/Modified**:
  - **Restructuring**: Restructured repository folders into `backend/` and `frontend/`.
  - **Database Migration**: Created `backend/config/database.js`, `backend/models/index.js`, and rewrote models/controllers to support Sequelize/Postgres with complete client compatibility.
  - **Docker & Compose**: Authored `backend/Dockerfile`, `frontend/Dockerfile`, `frontend/nginx.conf`, and root `docker-compose.yml`.
  - **Terraform Configuration**: Created reusable modules under `infra/modules/` and configurations for `dev` and `prod` under `infra/environments/`.
  - **GitHub Workflows**: Authored `infra.yml`, `build.yml` (Trivy), `deploy.yml` (ASG Refresh), and `sonarqube.yml`.
  - **Memory & Checklists**: Checked off tasks in `task.md` and logged the walkthrough.

## [2026-06-19T21:05:00+03:00] Refactored AWS Infrastructure to Community Modules & Unified Config
- **Task Accomplished**: Re-architected the infrastructure configurations to use standard AWS Registry community modules (VPC, ECR, RDS, ALB, ASG), deleted old custom module files, unified the codebase under `infra/`, created environment `.tfvars` files, and updated the GitHub Actions infrastructure workflow to run in `infra/` and inject variable overrides.
- **Files Created/Modified**:
  - **Terraform Restructuring**: Relocated `user_data.sh` to `infra/user_data.sh`, deleted `infra/modules/` and folder environments `infra/environments/dev/` and `infra/environments/prod/`.
  - **Unified Configurations**: Created/overwrote `infra/main.tf`, `infra/variables.tf`, `infra/outputs.tf`, `infra/versions.tf`.
  - **Variables Files**: Created `infra/environments/dev.tfvars` and `infra/environments/prod.tfvars`.
  - **GitHub Workflows**: Updated `.github/workflows/infra.yml`.
  - **Memory & Checklists**: Pushed commit logs to the remote branch `feat/infra-setup` and updated course memory track.

## [2026-06-19T21:25:00+03:00] Comprehensive Comments added to DevOps & Cloud Architecture
- **Task Accomplished**: Added line-by-line explanatory inline comments to all Docker orchestration, web routing, Terraform HCL infrastructure, and GitHub Action workflows, providing the engineering reasons behind every option and configuration value.
- **Files Created/Modified**:
  - **Docker & Container Orchestration**: [docker-compose.yml](file:///Users/sami/Desktop/DevOps%20Diploma/MidTerm%20Project%20/docker-compose.yml), [backend/Dockerfile](file:///Users/sami/Desktop/DevOps%20Diploma/MidTerm%20Project%20/backend/Dockerfile), [frontend/Dockerfile](file:///Users/sami/Desktop/DevOps%20Diploma/MidTerm%20Project%20/frontend/Dockerfile), [frontend/nginx.conf](file:///Users/sami/Desktop/DevOps%20Diploma/MidTerm%20Project%20/frontend/nginx.conf)
  - **Terraform AWS IaC**: [infra/main.tf](file:///Users/sami/Desktop/DevOps%20Diploma/MidTerm%20Project%20/infra/main.tf), [infra/variables.tf](file:///Users/sami/Desktop/DevOps%20Diploma/MidTerm%20Project%20/infra/variables.tf), [infra/outputs.tf](file:///Users/sami/Desktop/DevOps%20Diploma/MidTerm%20Project%20/infra/outputs.tf), [infra/providers.tf](file:///Users/sami/Desktop/DevOps%20Diploma/MidTerm%20Project%20/infra/providers.tf), [infra/versions.tf](file:///Users/sami/Desktop/DevOps%20Diploma/MidTerm%20Project%20/infra/versions.tf), [infra/user_data.sh](file:///Users/sami/Desktop/DevOps%20Diploma/MidTerm%20Project%20/infra/user_data.sh), [infra/environments/dev.tfvars](file:///Users/sami/Desktop/DevOps%20Diploma/MidTerm%20Project%20/infra/environments/dev.tfvars), [infra/environments/prod.tfvars](file:///Users/sami/Desktop/DevOps%20Diploma/MidTerm%20Project%20/infra/environments/prod.tfvars)
  - **GitHub Workflows**: [.github/workflows/infra.yml](file:///Users/sami/Desktop/DevOps%20Diploma/MidTerm%20Project%20/.github/workflows/infra.yml), [.github/workflows/build.yml](file:///Users/sami/Desktop/DevOps%20Diploma/MidTerm%20Project%20/.github/workflows/build.yml), [.github/workflows/deploy.yml](file:///Users/sami/Desktop/DevOps%20Diploma/MidTerm%20Project%20/.github/workflows/deploy.yml), [.github/workflows/sonarqube.yml](file:///Users/sami/Desktop/DevOps%20Diploma/MidTerm%20Project%20/.github/workflows/sonarqube.yml)

## [2026-06-19T21:28:00+03:00] Reconfigured VPC Module to Disable NAT Gateways
- **Task Accomplished**: Modified the community VPC module in the root `infra/main.tf` file, disabling NAT gateways (`enable_nat_gateway = false`) and removing related multi-AZ configuration parameters, as requested. The VPC is now restricted to use only the standard Internet Gateway.
- **Files Modified**:
  - [infra/main.tf](file:///Users/sami/Desktop/DevOps%20Diploma/MidTerm%20Project%20/infra/main.tf)

## [2026-06-19T21:35:00+03:00] Simplified Load Balancer Routing to HTTP-Only
- **Task Accomplished**: Removed HTTPS ingress parameters (port 443), TLS certificate checks, map merging functions, and conditional redirection checks from the ALB configuration. Simplified the listeners block to natively receive port 80 HTTP requests and simplified routing rules down to a single clean forward to the frontend and backend.
- **Files Modified**:
  - [infra/main.tf](file:///Users/sami/Desktop/DevOps%20Diploma/MidTerm%20Project%20/infra/main.tf)

## [2026-06-19T21:50:00+03:00] Reconfigured Infrastructure to Public-Only Subnet Topology
- **Task Accomplished**: Disallowed the creation of private subnets inside the VPC module, setting `map_public_ip_on_launch = true` so that all resources (RDS database and ASG virtual machines) are deployed directly in the public subnets and get assigned public IP addresses automatically on launch.
- **Files Modified**:
  - [infra/main.tf](file:///Users/sami/Desktop/DevOps%20Diploma/MidTerm%20Project%20/infra/main.tf)

## [2026-06-19T22:06:00+03:00] Simplified EC2 IAM Role Permissions
- **Task Accomplished**: Simplified the EC2 container instances IAM role by removing the commented SSM attachment and deleting the custom log/credentials read policy (`ec2_custom_policy`) and its attachment. The role is now restricted strictly to ECR Read-Only permissions so the Docker daemon can pull verified container images.
- **Files Modified**:
  - [infra/main.tf](file:///Users/sami/Desktop/DevOps%20Diploma/MidTerm%20Project%20/infra/main.tf)

## [2026-06-19T22:15:00+03:00] Migrated to Static AWS Credentials in CI/CD Workflows
- **Task Accomplished**: Removed the OpenID Connect (OIDC) provider, caller identity, and GitHub Actions IAM role/policy configurations from the Terraform codebase. Reconfigured GitHub workflows to authenticate using static `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` repository secrets, simplifying workflow security mapping.
- **Files Modified**:
  - [infra/main.tf](file:///Users/sami/Desktop/DevOps%20Diploma/MidTerm%20Project%20/infra/main.tf)
  - [infra/variables.tf](file:///Users/sami/Desktop/DevOps%20Diploma/MidTerm%20Project%20/infra/variables.tf)
  - [infra/environments/dev.tfvars](file:///Users/sami/Desktop/DevOps%20Diploma/MidTerm%20Project%20/infra/environments/dev.tfvars)
  - [infra/environments/prod.tfvars](file:///Users/sami/Desktop/DevOps%20Diploma/MidTerm%20Project%20/infra/environments/prod.tfvars)
  - [.github/workflows/infra.yml](file:///Users/sami/Desktop/DevOps%20Diploma/MidTerm%20Project%20/.github/workflows/infra.yml)
  - [.github/workflows/build.yml](file:///Users/sami/Desktop/DevOps%20Diploma/MidTerm%20Project%20/.github/workflows/build.yml)
  - [.github/workflows/deploy.yml](file:///Users/sami/Desktop/DevOps%20Diploma/MidTerm%20Project%20/.github/workflows/deploy.yml)
## [2026-06-19T22:34:00+03:00] Removed Orphaned IAM Outputs and Verified EC2 Role Deletion
- **Task Accomplished**: Cleaned up the orphaned `github_actions_role_arn` output in `infra/outputs.tf` which referenced the deleted OIDC role. Confirmed that no EC2 IAM roles, instance profiles, or policy attachments remain in the Terraform configuration, verifying alignment with static key authentication.
- **Files Modified**:
- [infra/outputs.tf](file:///Users/sami/Desktop/DevOps%20Diploma/MidTerm%20Project%20/infra/outputs.tf)

## [2026-06-19T22:45:00+03:00] Integrated AWS Secrets Manager for DB Credentials & Cleaned Up Variables
- **Task Accomplished**: Integrated AWS Secrets Manager data sources to dynamically retrieve database credentials (`username`/`password`) inside Terraform, decoding JSON string payloads and passing values to RDS and ASG bootstrapping scripts. Removed deprecated variables (`db_user`, `db_password`, and `private_subnets`) from variable mappings, `.tfvars` environments, and GitHub Action workflows. Checked and verified `jwt_secret` dependency.
- **Files Modified**:
  - [infra/main.tf](file:///Users/sami/Desktop/DevOps%20Diploma/MidTerm%20Project%20/infra/main.tf)
  - [infra/variables.tf](file:///Users/sami/Desktop/DevOps%20Diploma/MidTerm%20Project%20/infra/variables.tf)
  - [infra/environments/dev.tfvars](file:///Users/sami/Desktop/DevOps%20Diploma/MidTerm%20Project%20/infra/environments/dev.tfvars)
  - [infra/environments/prod.tfvars](file:///Users/sami/Desktop/DevOps%20Diploma/MidTerm%20Project%20/infra/environments/prod.tfvars)
  - [.github/workflows/infra.yml](file:///Users/sami/Desktop/DevOps%20Diploma/MidTerm%20Project%20/.github/workflows/infra.yml)

## [2026-06-19T23:08:00+03:00] Created Root Gitignore File
- **Task Accomplished**: Created a comprehensive `.gitignore` file at the root of the workspace to prevent tracking of Node packages, build artifacts, environmental secret keys, local Terraform state backends, and OS temp files.
- **Files Created**:
  - [.gitignore](file:///Users/sami/Desktop/DevOps%20Diploma/MidTerm%20Project%20/.gitignore)

## [2026-06-19T23:14:00+03:00] Integrated JWT Secret into AWS Secrets Manager
- **Task Accomplished**: Migrated the `jwt_secret` configuration into the same database credentials AWS Secrets Manager JSON payload. Refactored the Terraform Launch Template / ASG user data bootstrap template to load `jwt_secret` dynamically at run-time, removing `jwt_secret` inputs from parameters, `.tfvars` files, and workflows.
- **Files Modified**:
  - [infra/main.tf](file:///Users/sami/Desktop/DevOps%20Diploma/MidTerm%20Project%20/infra/main.tf)
  - [infra/variables.tf](file:///Users/sami/Desktop/DevOps%20Diploma/MidTerm%20Project%20/infra/variables.tf)
  - [infra/environments/dev.tfvars](file:///Users/sami/Desktop/DevOps%20Diploma/MidTerm%20Project%20/infra/environments/dev.tfvars)
  - [infra/environments/prod.tfvars](file:///Users/sami/Desktop/DevOps%20Diploma/MidTerm%20Project%20/infra/environments/prod.tfvars)
  - [.github/workflows/infra.yml](file:///Users/sami/Desktop/DevOps%20Diploma/MidTerm%20Project%20/.github/workflows/infra.yml)

## [2026-06-19T23:25:00+03:00] Configured Local S3 Backends and Updated AWS Region to eu-west-1
- **Task Accomplished**: Created environment-specific S3 backend configuration files (`dev.tfbackend` and `prod.tfbackend`) specifying the S3 bucket `midterm-project-state-s3` and region `eu-west-1`. Updated all `.tfvars` environment files to deploy inside region `eu-west-1` and availability zones `["eu-west-1a", "eu-west-1b"]`.
- **Files Created**:
  - [infra/environments/dev.tfbackend](file:///Users/sami/Desktop/DevOps%20Diploma/MidTerm%20Project%20/infra/environments/dev.tfbackend)
  - [infra/environments/prod.tfbackend](file:///Users/sami/Desktop/DevOps%20Diploma/MidTerm%20Project%20/infra/environments/prod.tfbackend)
- **Files Modified**:
  - [infra/environments/dev.tfvars](file:///Users/sami/Desktop/DevOps%20Diploma/MidTerm%20Project%20/infra/environments/dev.tfvars)
- [infra/environments/prod.tfvars](file:///Users/sami/Desktop/DevOps%20Diploma/MidTerm%20Project%20/infra/environments/prod.tfvars)

## [2026-06-19T23:35:00+03:00] Updated Workflow to Use HCL Backend Configuration Files
- **Task Accomplished**: Created unified `backend_prod.hcl` inside `infra/` and cleaned up deprecated backend configuration files (`backend._prod.hcl`, `dev.tfbackend`, `prod.tfbackend`). Updated the GitHub Actions workflow `infra.yml` to run `terraform init` with dynamic HCL configurations `backend_${{ github.event.inputs.environment }}.hcl` instead of passing separate inline parameters.
- **Files Created**:
  - [infra/backend_prod.hcl](file:///Users/sami/Desktop/DevOps%20Diploma/MidTerm%20Project%20/infra/backend_prod.hcl)
- **Files Modified**:
  - [.github/workflows/infra.yml](file:///Users/sami/Desktop/DevOps%20Diploma/MidTerm%20Project%20/.github/workflows/infra.yml)
- **Files Deleted**:
  - `infra/backend._prod.hcl`
  - `infra/environments/dev.tfbackend`
  - `infra/environments/prod.tfbackend`

## [2026-06-20T00:25:00+03:00] Fixed ALB Module v9 Compatibility Issues
- **Task Accomplished**: Updated the ALB module in `infra/main.tf` to fix target attachment and security group rule errors. Set `create_attachment = false` inside `frontend` and `backend` target groups because targets are managed dynamically via ASG, and updated ingress/egress rules to use the modern `cidr_ipv4` and `ip_protocol` properties required by `terraform-aws-modules/alb/aws` version 9.x.
- **Files Modified**:
  - [infra/main.tf](file:///Users/sami/Desktop/DevOps%20Diploma/MidTerm%20Project%20/infra/main.tf)

## [2026-06-20T00:38:00+03:00] Disabled ECR Lifecycle and Updated RDS PostgreSQL Version
- **Task Accomplished**: Disabled ECR lifecycle policies for both backend and frontend repositories by setting `create_lifecycle_policy = false` in `infra/main.tf` to avoid PutLifecyclePolicy errors. Upgraded the PostgreSQL database `engine_version` to `15.18` to use a supported version in `eu-west-1`. Verified HCL syntax via `terraform validate`.
- **Files Modified**:
  - [infra/main.tf](file:///Users/sami/Desktop/DevOps%20Diploma/MidTerm%20Project%20/infra/main.tf)

## [2026-06-20T04:42:00+03:00] Migrated Infrastructure from ASG to Single EC2 Instance (Simplified)
- **Task Accomplished**: Successfully migrated target infrastructure setup from ASG to a single EC2 instance (`aws_instance.web`). Simplified Application Load Balancer to forward port 80 traffic to a single `web` target group. Allowed SSH inbound access (port 22) on the host SG and supported SSH key pairs. Cleaned up variables, tfvars files, outputs, and workflows to route and deploy via SSH.
- **Files Modified**:
  - [infra/main.tf](file:///Users/sami/Desktop/DevOps%20Diploma/MidTerm%20Project%20/infra/main.tf)
  - [infra/variables.tf](file:///Users/sami/Desktop/DevOps%20Diploma/MidTerm%20Project%20/infra/variables.tf)
  - [infra/environments/dev.tfvars](file:///Users/sami/Desktop/DevOps%20Diploma/MidTerm%20Project%20/infra/environments/dev.tfvars)
  - [infra/environments/prod.tfvars](file:///Users/sami/Desktop/DevOps%20Diploma/MidTerm%20Project%20/infra/environments/prod.tfvars)
  - [infra/outputs.tf](file:///Users/sami/Desktop/DevOps%20Diploma/MidTerm%20Project%20/infra/outputs.tf)
  - [.github/workflows/deploy.yml](file:///Users/sami/Desktop/DevOps%20Diploma/MidTerm%20Project%20/.github/workflows/deploy.yml)

## [2026-06-20T15:21:00+03:00] Completely Removed Application Load Balancer (ALB)
- **Task Accomplished**: Modified infrastructure to completely remove the Application Load Balancer (ALB) module and its target group attachments. Updated the EC2 host security group rules to allow direct public ingress to ports 80 (HTTP) and 8000 (API) from any IP (`0.0.0.0/0`). Removed ALB DNS output and exposed EC2 public IP and ID output variables.
- **Files Modified**:
  - [infra/main.tf](file:///Users/sami/Desktop/DevOps%20Diploma/MidTerm%20Project%20/infra/main.tf)
  - [infra/outputs.tf](file:///Users/sami/Desktop/DevOps%20Diploma/MidTerm%20Project%20/infra/outputs.tf)


