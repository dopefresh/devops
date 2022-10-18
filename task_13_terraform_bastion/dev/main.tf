terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}

resource "aws_vpc" "vasilii-vpc" {
  cidr_block = "172.16.0.0/16"
  tags = {
    "Name" = "vasilii-vpc"
  }
}
