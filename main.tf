terraform {
  backend "s3" {
    bucket = "meu-terraform-state"
    key    = "envs/dev/terraform.tfstate"
    region = "us-east-1"

    access_key = "mock_access_key"
    secret_key = "mock_secret_key"
    dynamodb_table = "terraform-locks"

    endpoints = {
      s3       = "http://localhost:4566"
      dynamodb = "http://localhost:4566"
      sts      = "http://localhost:4566"
    }
    
    use_path_style              = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
    skip_region_validation      = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region                      = "us-east-1"
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  s3_use_path_style = true

  endpoints {
    s3  = "http://localhost:4566"
    ec2 = "http://localhost:4566"
  }
}

resource "aws_instance" "VM1" {
  ami           = "ami-011899242bb902164"
  instance_type = "t2.micro"
}