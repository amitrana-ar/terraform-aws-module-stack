variable "rds_name" {
  type = string
  description = "This is the name of RDS"
}

variable "rds_db_name" {
  type = string
  description = "This is the database name of RDS"
}

variable "rds_db_username" {
  type = string
  description = "This is the database username of RDS"
  sensitive = true
}

variable "rds_db_password" {
  type = string
  description = "This is the database password of RDS"
  sensitive = true  
}

variable "rds_instance_class" {
  type = string
  description = "This is the instance class of RDS"
}

variable "rds_storage_size" {
  type = number
  description = "This is the storage size of RDS"
  default = 20
}

variable "rds_storage_type" {
  type = string
  description = "This is the storage type of RDS"
  default = "gp2"
}