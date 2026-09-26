terraform {
  backend "s3" {
    bucket         = "qa-mghealth-terraform-states"
    region         = "ap-south-1"
    dynamodb_table = "qa-terraform-locks"
    encrypt        = true
  }
}
