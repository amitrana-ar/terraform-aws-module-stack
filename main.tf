module "dev-infra" {
    source = "./terra-module"
    env = "dev"
    ec2_instance_type = {
        apache-instance = {
            ami = "ami-01a00762f46d584a1"
            type = "t2.medium"
            user_data = file("./userdata/apache-install.sh")
        }
    }
    ec2_key_pair_name = "aws-keypair-mumbai"
    ec2_key_pair_public_key = file("./userdata/aws-keypair-mumbai.pub")
    vpc_name = "artechworld"
    s3_bucket = "artechworld-tf-4709"   
    loadbalancer_type = "application"
    loadbalancer-name = "artechworld-tf-lb"
    aws_db_name = "artechworldb"
    aws_rds_name = "artechworld-rds"
    aws_rds_username = "admin"
    aws_rds_password = "password123"
    aws_rds_engine = "mysql"
    aws_rds_engine_version = "8.0"
    aws_rds_instance_class = "db.t3.micro"
}