resource "aws_key_pair" "awskeypair" {
    key_name   = "${var.env}-${var.ec2_key_pair_name}}"
    public_key = var.ec2_key_pair_public_key
}

resource "aws_instance" "ec2_instance-public" {
    for_each = var.ec2_instance_type
    key_name = aws_key_pair.awskeypair.key_name
    ami           = each.value.ami
    instance_type = each.value.type
    subnet_id     = values(aws_subnet.vpc-subnet-public)[0].id
    associate_public_ip_address = true
    tags = {
      Name = "${var.env}-${each.key}"
    }
    vpc_security_group_ids = [aws_security_group.sg-public.id]
    root_block_device {
        volume_size = 10
    }
}

resource "aws_instance" "ec2_instance-private" {
    for_each = var.ec2_instance_type
    key_name = aws_key_pair.awskeypair.key_name
    ami           = each.value.ami
    instance_type = each.value.type
    subnet_id     = values(aws_subnet.vpc-subnet-private)[0].id
    associate_public_ip_address = false
    tags = {
      Name = "${var.env}-${each.key}"
    }
    user_data = each.value.user_data
    vpc_security_group_ids = [aws_security_group.sg-private.id]
    
    root_block_device {
        volume_size = 20
    }
}