terraform {
  backend "s3" {
    bucket       = "secure-landingzone-tfstate-2026-dev"
    key          = "dev/terraform.tfstate"
    region       = "eu-north-1"
    use_lockfile = true # <-- استبدلنا dynamodb_table بهذا السطر
    encrypt      = true
  }
}