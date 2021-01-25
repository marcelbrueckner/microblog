terraform {
    required_providers {
        aws = {
          source  = "hashicorp/aws"
          version = "~> 3.0"
        }
    }
}

provider "aws" {
  region = "eu-central-1"
}

resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "key" {
  key_name   = "microblog"
  public_key = tls_private_key.key.public_key_openssh
}

resource "time_sleep" "wait_10_seconds" {
  depends_on = [aws_key_pair.key]

  create_duration = "10s"
}

data "http" "current_ip_address"{
  url = "https://api.ipify.org"
}

#### Monitoring infrastructure ####

resource "aws_security_group" "monitoring_allow" {
  name        = "monitoring_allow_all"
  description = "Allow inbound traffic from my IP address"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${trimspace(data.http.current_ip_address.body)}/32"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    purpose = var.purpose
  }
}

resource "aws_instance" "monitoring" {
  # Avoid "Error launching source instance: InvalidKeyPair.NotFound: The key pair 'microblog' does not exist"
  depends_on = [time_sleep.wait_10_seconds]

  ami           = "ami-0e8286b71b81c3cc1"
  instance_type = "t2.micro"
  key_name      = "microblog"
  vpc_security_group_ids = [aws_security_group.monitoring_allow.id]

  tags = {
    purpose = var.purpose
  }
  volume_tags = {
    purpose = var.purpose
  }
}

data "aws_subnet" "monitoring" {
  id = aws_instance.monitoring.subnet_id
}


#### Application infrastructure ####

# Container registry for storing built container image
resource "aws_ecr_repository" "microblog" {
  name = "microblog"

  tags = {
    purpose = var.purpose
  }
}

data "aws_ecr_authorization_token" "token" {
  registry_id = aws_ecr_repository.microblog.registry_id
}

resource "aws_security_group" "microblog_allow" {
  name        = "microblog_allow"
  description = "Allow inbound traffic from my IP address and monitoring CIDR"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${trimspace(data.http.current_ip_address.body)}/32", data.aws_subnet.monitoring.cidr_block]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    purpose = var.purpose
  }
}

resource "aws_instance" "microblog" {
  # Avoid "Error launching source instance: InvalidKeyPair.NotFound: The key pair 'microblog' does not exist"
  depends_on = [time_sleep.wait_10_seconds]

  ami           = "ami-0e8286b71b81c3cc1"
  instance_type = "t2.micro"
  key_name      = "microblog"
  vpc_security_group_ids = [aws_security_group.microblog_allow.id]

  tags = {
    purpose = var.purpose
  }
  volume_tags = {
    purpose = var.purpose
  }
}
