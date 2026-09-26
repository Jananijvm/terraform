terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
       source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

# Region comes from AWS CLI profile / env vars
provider "aws" {
  default_tags {
    tags = local.common_tags
  }
}

provider "aws" {
  alias  = "backup"
  region = "ap-south-2"
  default_tags {
    tags = local.common_tags
  }
}