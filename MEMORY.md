# Agent Memory

## Project Context
This project is a DevOps Diploma repository containing multiple training sessions, including DevOps Mindset, Git, Linux, Docker, AWS Core Services, AWS DevOps (HA & Scaling), GitHub Actions & Workflows, and Terraform.

## Current Objective
Consolidate all labs and assignments starting from Session 1 (DevOps Mindset) up to Session 9 (Terraform) into a unified `all-labs/` directory, copying original instructions and providing fully functional code/configurations and comprehensive solutions for every single lab and assignment.

## State and History
- **2026-06-14:** Initialized the consolidation task. Approved the implementation plan and task list. Solved Topic 1 (DevOps Mindset), Topic 2 (Git Prep), Topic 3 (Linux & Docker Intro), Topic 4 (Docker Deep Dive), Topic 5 (Git Advanced), and Topic 6 (AWS Core Services).
- **2026-06-14 (Continued):** Solved Topic 7 (AWS DevOps HA & Scaling), migrated Topic 8 (GitLab CI -> GitHub Actions & Workflows), and solved Topic 9 (Terraform Modules & Auto Scaling Raw HCL codebase). Task checklist fully completed.
- **2026-06-14 (Slide Update):** Expanded the Terraform Session 2 presentation (`presentation.md` and `presentation.html`) with 3 new slides detailing variable types (primitives, collections, maps/objects), HCL declarations, and referencing syntax. Compiled the updated presentation deck into a PDF named `Modules , Variables and Loops.pdf`.
- **2026-06-16:** Enhanced the midterm exam question bank (`midterm_questions_bank.md`) to align all questions directly with the taught course labs and concepts, replacing file path details and academic questions (like git config paths and Copy-on-Write) with practical levels and commands.
- **2026-06-16 (Formatting Update):** Formatted the midterm exam question bank (`midterm_questions_bank.md`) so that correct answer choices are bolded directly in the lists rather than being written separately under the choices, making the question bank much cleaner to review.
- **2026-06-16 (Shuffling & Category Removal):** Shuffled all 130 questions in the midterm exam question bank (`midterm_questions_bank.md`) randomly and renumbered them sequentially. Removed all category-specific subheadings and the Table of Contents, leaving a single, unified list of questions with only the document title.
- **2026-06-16 (Circle Formatting):** Positioned a solid circle symbol `●` at the end of the line inside the bold markers for each correct answer choice in `midterm_questions_bank.md`.
- **2026-06-16 (Triangle & PDF Compilation):** Updated all 130 correct options inside `midterm_questions_bank.md` to display a solid triangle symbol `▲` at the end instead of the circle `●`. Compiled the updated question bank to a professionally designed PDF named `midterm_questions_bank.pdf` at the workspace root using headless Chrome print features.
- **2026-06-16 (Q5 Replacement):** Replaced the deleted Question 5 with a new practical question about AWS NAT Gateways, maintaining the total count at 130 questions, and regenerated `midterm_questions_bank.pdf`.
- **2026-06-17:** Completed the MidTerm Project DevOps platform execution. Restructured repository layout into root `backend/` and `frontend/` folders, migrated Node application to Sequelize PostgreSQL (matching `_id` outputs for React frontend), containerized both services with Docker/Docker Compose, built Terraform multi-environment infra modules (VPC, RDS, ALB, IAM, EC2 ASG), and configured 4 GitHub Actions OIDC pipelines (Infra, Build with Trivy, Deploy with ASG Instance Refresh, and SonarQube).
