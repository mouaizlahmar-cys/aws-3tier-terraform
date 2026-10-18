# 1. Groupe de sous-réseaux pour RDS (sur 2 AZs isolées)
resource "aws_db_subnet_group" "main" {
  name       = "${var.environment}-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name        = "${var.environment}-db-subnet-group"
    Environment = var.environment
  }
}

# 2. Mot de passe aléatoire sécurisé (enregistré dans le State Terraform)
resource "random_password" "db_password" {
  length  = 16
  special = false
}

# 3. Instance RDS PostgreSQL
resource "aws_db_instance" "postgres" {
  identifier             = "${var.environment}-postgres-db"
  allocated_storage      = 20
  max_allocated_storage  = 100
  engine                 = "postgres"
  engine_version         = "15"
  instance_class         = "db.t3.micro" # Adapté au Free Tier / Dev
  db_name                = var.db_name
  username               = var.db_username
  password               = random_password.db_password.result
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.security_group_id]

  publicly_accessible = false
  skip_final_snapshot = true # Adapté pour l'environnement DEV
  storage_encrypted   = true # Conforme DevSecOps

  tags = {
    Name        = "${var.environment}-postgres-db"
    Environment = var.environment
  }
}