terraform {
  backend "s3" {
    bucket         = "dev-mghealth-terraform-state"
    region         = "ap-south-1"
    dynamodb_table = "dev-terraform-locks"
    encrypt        = true
  }
}
