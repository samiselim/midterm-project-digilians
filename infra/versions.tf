# Declare settings block for Terraform runtime requirements and providers.
terraform {
  # Enforce Terraform CLI version >= 1.5.0 to support newer configurations (such as import blocks, upgraded variables handling, and official module features).
  required_version = ">= 1.5.0"

  # Specify providers that this configuration requires to download.
  required_providers {
    # Define the configuration rules for the official AWS provider.
    aws = {
      # Download the provider from HashiCorp's official provider registry.
      source = "hashicorp/aws"
      # Pin the version to v5.x using the pessimistic boundary operator (~>), allowing non-breaking minor updates but blocking major upgrades.
      version = "~> 5.0"
    }
  }

  # Declare an empty S3 backend block. Keeping it empty allows us to dynamically pass backend details (bucket name, key, AWS region, DynamoDB table) 
  # via the CLI during "terraform init -backend-config=..." in CI/CD workflows, facilitating multi-environment backend setups.
  backend "s3" {}
}

