# ── Terraform settings ────────────────────────────────────────────
terraform {
  # Which Terraform CLI versions may run this config.
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws" # where to download it from
      version = "~> 5.0"        # "5.x, but not 6.0" — pessimistic operator
    }
  }
}

# ── Provider ──────────────────────────────────────────────────────
# Credentials are NOT here. The provider reads AWS_PROFILE and your
# cached SSO token. Never put keys in this block.
provider "aws" {
  region = "us-east-1"
}

# ── The bucket ────────────────────────────────────────────────────
resource "aws_s3_bucket" "audit_logs" {
  bucket = "audit-logs-lab-s3-0001"

  tags = {
    Name        = "audit-logs-lab"
    Environment = "lab"
    ManagedBy   = "terraform"
  }

}

resource "aws_s3_bucket_public_access_block" "audit_logs" {
  # Reference, not a string. This is what creates the dependency graph.
  bucket = aws_s3_bucket.audit_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "audit_logs" {
  bucket = aws_s3_bucket.audit_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256" # SSE-S3. KMS comes in Milestone 2.
    }
  }
}

resource "aws_s3_bucket_versioning" "audit_logs" {
  bucket = aws_s3_bucket.audit_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}