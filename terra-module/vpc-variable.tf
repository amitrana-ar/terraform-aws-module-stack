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

variable "ingress_ssh_port" {
    type = number
    default = 22
    description = "The SSH port for the security group"
}
variable "ingress_ssh_cidr_blocks-public" {
    type = list(string)
    default = ["0.0.0.0/0"]
}

variable "ingress_ssh_cidr_blocks-private" {
    type = list(string)
    default = ["0.0.0.0/0"]
}

variable "allow_cidr_blocks" {
    type = list(string)
    default = ["0.0.0.0/0"]
}

variable "rds_allow_cidr_blocks" {
    type = list(string)
    default = ["0.0.0.0/0"]
}