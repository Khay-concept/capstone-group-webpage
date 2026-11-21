terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_security_group" "flask_sg" {
  name        = "capstone-flask-sg"
  description = "Allow HTTP (80) and SSH (22) inbound traffic"

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "flask_server" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.flask_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y git python3-pip
              git clone ${var.repo_url} /opt/capstone-app
              cd /opt/capstone-app/app
              pip3 install -r requirements.txt
              nohup gunicorn -w 2 -b 0.0.0.0:80 app:app > /var/log/flask-app.log 2>&1 &
              EOF

  tags = {
    Name = "Capstone-Group1-Flask-App"
  }
}
