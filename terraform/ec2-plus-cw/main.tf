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
    region = "us-east-1"
}

resource "aws_instance" "monitored_server" {
    ami = "ami-053a45fff0a704a47"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.ec2_sg.id]
    key_name = "KEY_BENARDI"

    tags = {
        Name = "CW-Monitored-Server"
    }

    user_data = <<-EOF
                #!/usr/bin/env bash
                sudo yum install stress -y
                EOF
}

resource "aws_security_group" "ec2_sg" {
    name = "ec2-sg"
    vpc_id = "vpc-040f133c545ac6b23"

    dynamic "ingress" {
        for_each = ["187.19.131.11/32"]
        content {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [ingress.value]
        }
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
    alarm_name = "CPU_Utilization_EC2_Instance_Alarm"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods = 2
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = 60
    statistic = "Average"
    threshold = 15
    dimensions = {
        InstanceId = aws_instance.monitored_server.id
    }

    alarm_description = "Raises alarm when CPU utilization is greater than or equal to 15%"
}

output "instance_ip_addr" {
    value = aws_instance.monitored_server.public_ip
}
