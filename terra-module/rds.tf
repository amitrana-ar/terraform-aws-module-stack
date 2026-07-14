locals {
    rds_creds = jsondecode(aws_secretsmanager_secret_version.rds_secret_version.secret_string)
}

resource "aws_db_instance" "aws_rds" {
    identifier           = "${var.env}-${var.rds_name}"
    engine               = "mysql"
    engine_version       = "8.0"
    instance_class       = var.rds_instance_class
    allocated_storage    = var.rds_storage_size
    storage_type         = var.rds_storage_type
    db_name              = var.rds_db_name
    username             = local.rds_creds["username"]
    password             = local.rds_creds["password"]
    
    db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
    vpc_security_group_ids = [aws_security_group.sg-rds.id]
    
    skip_final_snapshot  = true    
    tags = {
      name = "${var.env}-${var.rds_name}"
    }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.env}-${var.rds_name}-subnet-group"
  subnet_ids = values(aws_subnet.vpc-subnet-private)[*].id 

  tags = {
    Name        = "${var.env}-${var.rds_name}-subnet-group"
    Environment = var.env
  }
}