resource "aws_lb" "terraform-lb" {
    name               = "${var.env}-${var.loadbalancer-name}"
    internal           = false
    load_balancer_type = var.loadbalancer_type
    security_groups    = [aws_security_group.sg.id]
    subnets            = values(aws_subnet.vpc-subnet-public)[*].id
    enable_deletion_protection = false
    tags = {
        Name = "${var.env}-${var.loadbalancer-name}"
        Environment = var.env
    }
}

resource "aws_lb_target_group" "terraform-lb-tg" {
    name     = "${var.env}-${var.loadbalancer-name}-tg"
    port     = 80
    protocol = "HTTP"
    vpc_id   = aws_vpc.aws_vpc.id
    health_check {
        path                = "/"
        interval            = 30
        timeout             = 5
        healthy_threshold   = 5
        unhealthy_threshold = 2
        matcher             = "200-399"
    }
    tags = {
        Name = "${var.env}-${var.loadbalancer-name}-tg"
        Environment = var.env
    }
}

resource "aws_lb_target_group_attachment" "terraform-lb-tg-attachment" {
    for_each = aws_instance.ec2_instance-private
    target_group_arn = aws_lb_target_group.terraform-lb-tg.arn
    target_id        = each.value.id
    port             = 80
}

resource "aws_lb_listener" "terraform-lb-listener" {
    load_balancer_arn = aws_lb.terraform-lb.arn
    port              = 80
    protocol          = "HTTP"
    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.terraform-lb-tg.arn
    }
}