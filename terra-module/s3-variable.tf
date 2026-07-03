variable "s3_bucket" {
    type = string
    description = "The name of the S3 bucket"
}

variable "s3_versioning" {
    type = string
    description = "Enable versioning for S3 bucket"
    default = "Enabled"
}

variable "s3_block_public_acls" {
    type = string
    description = "S3 Block Public ACLs"
    default = "true"
}

variable "s3_block_public_policy" {
    type = string
    description = "S3 Block Public Policy"
    default = "true"
}

variable "s3_ignore_public_acls" {
    type = string
    description = "S3 Ignore Public ACLs"
    default = "true"
}

variable "s3_restrict_public_buckets" {
    type = string
    description = "S3 Restrict Public Buckets"
    default = "true"
}

variable "sse_algorithm" {
    type = string
    description = "Server-side encryption algorithm"
    default = "AES256"
}