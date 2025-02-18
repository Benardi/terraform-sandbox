
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
provider "aws" {
  profile = "admin-general"
  region  = "us-east-1"
}

resource "aws_instance" "first_server" {
  ami                    = "ami-053a45fff0a704a47"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name               = "KEY_BENARDI"

  tags = {
    Name = "First-EC2-Instance-Via-Terraform"
  }
}

resource "aws_security_group" "ec2_sg" {
  name   = "ec2-sg"
  vpc_id = "vpc-040f133c545ac6b23"

  dynamic "ingress" {
    for_each = ["187.19.131.11/32"]
    content {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_s3_bucket" "first_bucket" {
  bucket = "benardis-first-bucket"
  tags = {
    Name = "KoalaBucket"
  }
}