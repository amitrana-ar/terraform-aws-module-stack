resource "aws_iam_role" "ec2_role" {
  name = "${var.env}-${var.vpc_name}-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
  tags = {
    Name = "${var.env}-${var.vpc_name}-ec2-role"
    Environment = var.env
  }
}

resource "aws_iam_policy" "ec2_policy" {
  name = "${var.env}-${var.vpc_name}-ec2-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:s3:::${var.s3_bucket}",
          "arn:aws:s3:::${var.s3_bucket}/*"
        ]
      }
    ]
  })
  tags = {
    Name = "${var.env}-${var.vpc_name}-ec2-policy"
    Environment = var.env
  }
}

resource "aws_iam_role_policy_attachment" "ec2_role_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_policy.arn
}