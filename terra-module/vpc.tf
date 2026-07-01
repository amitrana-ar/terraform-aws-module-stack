resource "aws_vpc" "aws_vpc" {
    cidr_block          = var.vpc_cidr_block
    tags = {
        Name = "${var.env}-${var.vpc_name}"
        Environment = var.env
    }
}

resource "aws_subnet" "vpc-subnet-public" {
    for_each = toset(var.vpc_availability_zone)
    vpc_id             = aws_vpc.aws_vpc.id
    cidr_block         = cidrsubnet(var.vpc_cidr_block, 8, index(var.vpc_availability_zone, each.value) + 5)
    availability_zone = each.value
    map_public_ip_on_launch = true
    tags = {
        Name = "${var.env}-${var.vpc_name}-subnet-public"
        Environment = var.env
    }
}

resource "aws_subnet" "vpc-subnet-private" {
    for_each = toset(var.vpc_availability_zone)
    vpc_id             = aws_vpc.aws_vpc.id
    cidr_block         = cidrsubnet(var.vpc_cidr_block, 8, index(var.vpc_availability_zone, each.value) + 10)
    availability_zone = each.value
    map_public_ip_on_launch = false
    tags = {
        Name = "${var.env}-${var.vpc_name}-subnet-private"
        Environment = var.env
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.aws_vpc.id
    tags = {
        Name = "${var.env}-${var.vpc_name}-igw"
        Environment = var.env
    }
}

resource "aws_eip" "nat-eip" {
    domain = "vpc"
    tags = {
        Name = "${var.env}-${var.vpc_name}-nat-eip"
        Environment = var.env
    }
}

resource "aws_nat_gateway" "nt-gateway" {
    allocation_id = aws_eip.nat-eip.id
    subnet_id = values(aws_subnet.vpc-subnet-public)[0].id
    tags = {
        Name = "${var.env}-${var.vpc_name}-nat-gateway"
        Environment = var.env
    }
}

resource "aws_route_table" "rt-public" {
    vpc_id = aws_vpc.aws_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
        Name = "${var.env}-${var.vpc_name}-rt-public"
        Environment = var.env
    }
}

resource "aws_route_table" "rt-private" {
    vpc_id = aws_vpc.aws_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.nt-gateway.id
    }
    tags = {
        Name = "${var.env}-${var.vpc_name}-rt-private"
        Environment = var.env
    }
}

resource "aws_route_table_association" "rt_association-public" {
    for_each = aws_subnet.vpc-subnet-public
    subnet_id      = each.value.id
    route_table_id = aws_route_table.rt-public.id
}

resource "aws_route_table_association" "rt_association-private" {
    for_each = aws_subnet.vpc-subnet-private
    subnet_id      = each.value.id
    route_table_id = aws_route_table.rt-private.id
}

resource "aws_security_group" "sg" {
    vpc_id      = aws_vpc.aws_vpc.id
    tags = {
        Name = "${var.env}-${var.vpc_name}-sg"
        Environment = var.env
    }

    ingress {
        from_port   = var.ec2_ingress_ssh_port
        to_port     = var.ec2_ingress_ssh_port
        protocol    = "tcp"
        cidr_blocks = var.ec2_ssh_cidr_blocks
    }

    ingress {
        from_port   = var.ec2_ingress_http_port
        to_port     = var.ec2_ingress_http_port
        protocol    = "tcp"
        cidr_blocks = var.ec2_http_cidr_blocks
    }

    ingress {
        from_port   = var.ec2_ingress_https_port
        to_port     = var.ec2_ingress_https_port
        protocol    = "tcp"
        cidr_blocks = var.ec2_https_cidr_blocks
    }

    egress {
        from_port   = var.ec2_egress_all_port
        to_port     = var.ec2_egress_all_port
        protocol    = "-1"
        cidr_blocks = var.ec2_egress_all_cidr_blocks
    }
}

