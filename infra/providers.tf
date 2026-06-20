provider "aws" {
  # Dynamically set the deployment region using the "aws_region" variable, ensuring all resources are provisioned in the desired geographic location.
  region = var.aws_region
}

