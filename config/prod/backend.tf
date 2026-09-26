terraform {
  backend "s3" {
    bucket         = "prod-mghealth-terraform-states"
    region         = "ap-south-1"
    dynamodb_table = "prod-terraform-locks"
    encrypt        = true
  }
}
