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