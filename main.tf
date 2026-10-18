terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1" # تقدر تبدلها إذا حاب منطقة أخرى
}

# 1. إنشاء S3 Bucket لحفظ الـ State File
resource "aws_s3_bucket" "terraform_state" {
  bucket        = "secure-landingzone-tfstate-2026-dev" # لازم يكون اسم فريد فـ AWS كامل
  force_destroy = true

  tags = {
    Name        = "Terraform-State-Bucket"
    Environment = "Dev"
    Project     = "Secure-Landing-Zone"
  }
}

# 2. تفعيل الـ Versioning (حفظ النسخ القديمة لملف الـ State)
resource "aws_s3_bucket_versioning" "state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# 3. تشفير الـ Bucket بـ AES256 لحماية البيانات الحساسة
resource "aws_s3_bucket_server_side_encryption_configuration" "state_encryption" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# 4. غلق الوصول العام تماماً (Public Access Block)
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 5. إنشاء جدول DynamoDB لمنع التضارب (State Locking)
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "secure-landingzone-tf-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform-State-Lock-Table"
    Environment = "Dev"
    Project     = "Secure-Landing-Zone"
  }
}
# استدعاء موديول الشبكة
module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr           = "10.0.0.0/16"
  environment        = "dev"
  availability_zones = ["eu-north-1a", "eu-north-1b"]
  enable_nat_gateway = true # تقدر ترجعها false كي تحب ما تخلص والو فـ AWS
}
module "security_groups" {
  source      = "./modules/security_groups"
  vpc_id      = module.vpc.vpc_id
  environment = "dev"
}
module "ec2" {
  source            = "./modules/ec2"
  environment       = "dev"
  subnet_id         = module.vpc.private_app_subnet_ids[0] # السيرفر يتحط فـ أول Private App Subnet
  security_group_id = module.security_groups.app_security_group_id
  instance_type     = "t3.micro"
}
# Sortie requise dans modules/vpc/outputs.tf : isolated_db_subnet_ids
module "rds" {
  source            = "./modules/rds"
  environment       = "dev"
  subnet_ids        = module.vpc.isolated_db_subnet_ids
  security_group_id = module.security_groups.db_security_group_id
}