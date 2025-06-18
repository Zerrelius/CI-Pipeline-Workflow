# S3 Bucket für Terraform State (falls nicht existiert)
resource "aws_s3_bucket" "terraform_state" {
  bucket        = "terraform-state-ci-pipeline-${random_id.bucket_suffix.hex}"
  force_destroy = true

  tags = {
    Name        = "Terraform State Bucket"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Output des Bucket-Namens
output "terraform_state_bucket" {
  description = "Name of the S3 bucket for Terraform state"
  value       = aws_s3_bucket.terraform_state.bucket
}