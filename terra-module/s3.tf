resource "aws_s3_bucket" s3_bucket {
  bucket = var.s3_bucket
  force_destroy = "true"
  tags = {
    Environment = var.env
  }
}

resource "aws_s3_bucket_versioning" "s3_versioning" {
  bucket = aws_s3_bucket.s3_bucket.id
  versioning_configuration {
    status = var.s3_versioning
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_sse_config" {
  bucket = aws_s3_bucket.s3_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = var.sse_algorithm
    }
  }
}

resource "aws_s3_bucket_public_access_block" "s3_public_access_block" {
  bucket = aws_s3_bucket.s3_bucket.id

  block_public_acls       = var.s3_block_public_acls
  block_public_policy     = var.s3_block_public_policy
  ignore_public_acls      = var.s3_ignore_public_acls
  restrict_public_buckets = var.s3_restrict_public_buckets
}

resource "aws_s3_bucket_logging" "s3_logging" {
  bucket = aws_s3_bucket.s3_bucket.id

  target_bucket = aws_s3_bucket.s3_bucket.id
  target_prefix = "logs/"
}