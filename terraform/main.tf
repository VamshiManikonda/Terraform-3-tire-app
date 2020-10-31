provider "aws" {
  region  = var.region
  access_key = var.access_key
  secret_key = var.secret_key
  version = "~> 2.0"
}

data "aws_ami" "amazon_linux" {

  most_recent = true
  owners = ["amazon"]

  filter {
    name = "name"

    values = [
      "amzn-ami-hvm-*-x86_64-gp2",
    ]
  }

  filter {
    name = "owner-alias"

    values = [
      "amazon",
    ]
  }
}



