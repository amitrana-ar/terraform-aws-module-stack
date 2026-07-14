resource "aws_autoscaling_group" "autoscalling" {
  name                      = "${var.env}-autoscaling-group"
  max_size                  = 3
  min_size                  = 1
  desired_capacity          = 1
  vpc_zone_identifier       = values(aws_subnet.vpc-subnet-private)[*].id
  launch_template {
    name    = aws_launch_template.launch_config.name
    version = aws_launch_template.launch_config.latest_version
  }
  health_check_type         = "EC2"
  health_check_grace_period = 300
  target_group_arns = [aws_lb_target_group.terraform-lb-tg.arn]

  tag {
    key                 = "Name"
    value               = "${var.env}-autoscaling-group"
    propagate_at_launch = true
  }
}

resource "aws_launch_template" "launch_config" {
  name          = "${var.env}-launch-configuration"
  image_id      = var.ec2_instance_type["apache-instance"]["ami"]
  instance_type = var.ec2_instance_type["apache-instance"]["type"]
  key_name      = aws_key_pair.awskeypair.key_name
  user_data     = base64encode(var.ec2_instance_type["apache-instance"]["user_data"])
  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.sg-private.id]
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "scale_out" {
  name                   = "${var.env}-scale-out-policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.autoscalling.name
}

resource "aws_autoscaling_policy" "scale_in" {
  name                   = "${var.env}-scale-in-policy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.autoscalling.name
}

resource "aws_cloudwatch_metric_alarm" "scale_out_alarm" {
  alarm_name          = "${var.env}-scale-out-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name           = "CPUUtilization"
  namespace             = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 70
  alarm_actions       = [aws_autoscaling_policy.scale_out.arn]
}

resource "aws_cloudwatch_metric_alarm" "scale_in_alarm" {
  alarm_name          = "${var.env}-scale-in-alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name           = "CPUUtilization"
  namespace             = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 30
  alarm_actions       = [aws_autoscaling_policy.scale_in.arn]
}