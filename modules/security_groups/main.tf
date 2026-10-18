resource "aws_security_group" "app" {
  name        = "${var.environment}-app-sg"
  description = "Security group for application instances"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
    description = "Allow HTTPS traffic"
    from_port   = 443       
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-app-sg"
    Environment = var.environment
  }
}

# 2. Security Group لقاعدة البيانات (Database Tier)
resource "aws_security_group" "db" {
  name        = "${var.environment}-db-sg"
  description = "Security group for database instances"
  vpc_id      = var.vpc_id

  # السماح بالاتصال فقط من السيرفرات التابعة لـ app_sg على منفذ PostgreSQL (5432)
  ingress {
    description     = "Allow PostgreSQL access from App SG only"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id] # ربط أمني متبادل دقيق
  }

  tags = {
    Name        = "${var.environment}-db-sg"
    Environment = var.environment
  }
}