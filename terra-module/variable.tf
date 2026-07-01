variable "ec2_instance_type" {
    type = map(object({
      ami = string
      type = string
      user_data = string
    }))
}

# variable "ec2_instance_count" {
#     type = number
#     description = "This is the count of Instance"
# }

variable "ec2_key_pair_name" {
    type = string
    description = "This is the public key for the key pair"
}

variable "ec2_key_pair_public_key" {
    type = string
    description = "This is the public key for the key pair"
}

variable "ec2_root_volume_size" {
    type = number
    description = "This is the size of the root volume in GB"
    default = 20
}

variable "vpc_name" {
    type = string
    description = "This is the name of the VPC"
}

variable "vpc_cidr_block" {
    type = string
    description = "This is the CIDR block for the VPC"
    default = "10.0.0.0/16"
}

variable "vpc_availability_zone" {
    type = list(string)
    description = "This is the availability zone for the VPC"
    default = ["ap-south-1a", "ap-south-1b"]
    validation {
      #1. Ensure exactly 2 zones are provided
      #2. Ensure both zones belong to the approved list
      condition = (
        length(var.vpc_availability_zone) == 2 && 
        alltrue([for az in var.vpc_availability_zone : contains(["ap-south-1a", "ap-south-1b", "ap-south-1c"], az)])
      )
      error_message = "Exactly 2 availability zones must be provided and they must be from the approved list: ap-south-1a, ap-south-1b, ap-south-1c."
    }
}

variable "ec2_ingress_ssh_port" {
    type = number
    default = 22
    description = "The SSH port for the security group"
}
variable "ec2_ssh_cidr_blocks" {
    type = list(string)
    default = ["0.0.0.0/0"]
}

variable "ec2_http_cidr_blocks" {
    type = list(string)
    default = ["0.0.0.0/0"]
}

variable "ec2_ingress_http_port" {
    type = number
    default = 80
    description = "The HTTP port for the security group"
}

variable "ec2_https_cidr_blocks" {
    type = list(string)
    default = ["0.0.0.0/0"]
}


variable "ec2_ingress_https_port" {
    type = number
    default = 443
    description = "The HTTPS port for the security group"
}

variable "ec2_egress_all_port" {
    type = number
    default = 0
    description = "The All port for the security group"
}

variable "ec2_egress_all_cidr_blocks" {
    type = list(string)
    default = ["0.0.0.0/0"]
}

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

variable "env" {
    type = string
    description = "The environment name"
}

variable "loadbalancer_type" {
    type = string
    description = "The type of load balancer"
}

variable "loadbalancer-name" {
    type = string
    description = "The name of the load balancer"
}