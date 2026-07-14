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

resource "aws_security_group" "sg-public" {
    vpc_id      = aws_vpc.aws_vpc.id
    tags = {
        Name = "${var.env}-${var.vpc_name}-sg-public"
        Environment = var.env
    }
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = var.ingress_ssh_cidr_blocks-public
    }
    egress {
        from_port   = 0 
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = var.allow_cidr_blocks
    }
}

resource "aws_security_group" "sg-private" {
    vpc_id      = aws_vpc.aws_vpc.id
    tags = {
        Name = "${var.env}-${var.vpc_name}-sg-private"
        Environment = var.env
    }
    ingress {
        from_port   = 22    
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = var.ingress_ssh_cidr_blocks-private
    }
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = var.allow_cidr_blocks
    }
    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = var.allow_cidr_blocks
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = var.allow_cidr_blocks
    }
}

resource "aws_security_group" "sg-lb" {
    vpc_id      = aws_vpc.aws_vpc.id
    tags = {
        Name = "${var.env}-${var.vpc_name}-sg-lb"
        Environment = var.env
    }
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = var.allow_cidr_blocks
    }
    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = var.allow_cidr_blocks
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = var.allow_cidr_blocks
    }
}

resource "aws_security_group" "sg-rds" {
    vpc_id      = aws_vpc.aws_vpc.id
    tags = {
        Name = "${var.env}-${var.vpc_name}-sg-rds"
        Environment = var.env
    }
        ingress {
        from_port   = 3306 #SQL PORT
        to_port     = 3306
        protocol    = "tcp"
        security_groups = [aws_security_group.sg-private.id]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = var.allow_cidr_blocks
    }
}
