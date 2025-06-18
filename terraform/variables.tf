variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "ci-pipeline-workflow"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "ssh_public_key" {
  description = "SSH public key for EC2 access"
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC... your-public-key"
}