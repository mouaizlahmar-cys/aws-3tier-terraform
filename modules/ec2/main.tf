# 1. البحث الأوتوماتيكي عن أحدث صورة Amazon Linux 2023
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# 2. إنشاء IAM Role للـ SSM (Session Manager) لتفادي استخدام SSH
resource "aws_iam_role" "ec2_ssm" {
  name = "${var.environment}-ec2-ssm-role"

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
}

# ربط الـ Role بـ Policy الافتراضية لـ SSM
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ec2_ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# إنشاء Instance Profile للـ EC2
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.environment}-ec2-ssm-profile"
  role = aws_iam_role.ec2_ssm.name
}

# 3. إنشاء سيرفر الـ EC2 فـ Private Subnet
resource "aws_instance" "app" {
  ami                  = data.aws_ami.amazon_linux_2023.id
  instance_type        = var.instance_type
  subnet_id            = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from AWS Enterprise DevSecOps Tier!</h1>" > /var/www/html/index.html
              EOF

  tags = {
    Name        = "${var.environment}-app-server"
    Environment = var.environment
  }
}