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

variable "env" {
    type = string
    description = "The environment name"
}