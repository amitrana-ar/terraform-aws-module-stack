variable "aws_rds_name" {
  type = string
  description = "This is the name of RDS"
}

variable "aws_db_name" {
  type = string
  description = "This is the database name of RDS"
}

variable "aws_rds_username" {
  type = string
  description = "This is the username of RDS"
}

variable "aws_rds_password" {
  type = string
  description = "This is the password of RDS"
}

variable "aws_rds_engine" {
  type = string
  description = "This is the engine of RDS"
}

variable "aws_rds_engine_version" {
  type = string
  description = "This is the engine version of RDS"
}

variable "aws_rds_instance_class" {
  type = string
  description = "This is the instance class of RDS"
}
