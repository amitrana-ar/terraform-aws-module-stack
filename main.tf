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
    ec2_key_pair_name = "keyname"
    ec2_key_pair_public_key = file("./userdata/keyname.pub")
    vpc_name = "artechworld"
    s3_bucket = "artechworld-tf-4709"   
    loadbalancer_type = "application"
    loadbalancer-name = "artechworld-tf-lb"
}

module "prod-infra" {
    source = "./terra-module"
    env = "prod"
    ec2_instance_type = {
        apache-instance = {
            ami = "ami-006f82a1d5a27da54"
            type = "t2.medium"
            user_data = file("./userdata/apache-install.sh")
        }
    }
    ec2_key_pair_name = "keyname"
    ec2_key_pair_public_key = file("./userdata/keyname.pub")
    s3_bucket = "prod-ar-tf-4709"   
    vpc_name = "artechworld"
    loadbalancer_type = "application"
    loadbalancer-name = "artechworld-tf-lb"
}