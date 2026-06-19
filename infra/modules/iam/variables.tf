variable "env" {
  description = "The environment name"
  type        = string
}

variable "github_repo" {
  description = "The target GitHub repository in format 'org/repo' (e.g. 'sami/MidTerm-Project')"
  type        = string
  default     = "*/*"
}

variable "create_oidc_provider" {
  description = "Whether to create the GitHub OpenID Connect provider. Set to false if it already exists in the AWS account."
  type        = bool
  default     = true
}
