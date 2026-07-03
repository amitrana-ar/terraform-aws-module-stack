resource "aws_db_instance" "aws_rds" {
    engine               = var.aws_rds_engine
    engine_version       = var.aws_rds_engine_version
    instance_class       = var.aws_rds_instance_class
    db_name              = var.aws_db_name
    username             = var.aws_rds_username
    password             = var.aws_rds_password
    parameter_group_name = "default.mysql8.0"
    skip_final_snapshot  = true
    db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
    allocated_storage    = 20
    storage_type         = "gp2"
    vpc_security_group_ids = [aws_security_group.sg-rds.id]
    tags = {
      name = "${var.env}-${var.aws_rds_name}"
    }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.env}-${var.aws_rds_name}-subnet-group"
  subnet_ids = [for subnet in aws_subnet.vpc-subnet-private : subnet.id]

  tags = {
    Name        = "${var.env}-${var.aws_rds_name}-subnet-group"
    Environment = var.env
  }
}