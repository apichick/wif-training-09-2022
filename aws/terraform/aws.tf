/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

provider "aws" {
  region = var.region
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_cidr_block
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  route {
    ipv6_cidr_block = "::/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
}

resource "aws_route_table_association" "public_subnet_route_table_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "tls_private_key" "key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "key_pair" {
  key_name   = "vm-private-key"
  public_key = tls_private_key.key_pair.public_key_openssh
}

resource "aws_instance" "vm" {
  ami                         = var.vm_config.ami
  instance_type               = var.vm_config.instance_type
  subnet_id                   = aws_subnet.public_subnet.id
  key_name                    = aws_key_pair.key_pair.key_name
  iam_instance_profile        = aws_iam_instance_profile.profile.name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.bastion_security_group.id]
  user_data                   = <<EOT
#!/bin/sh

sudo tee -a /etc/yum.repos.d/google-cloud-sdk.repo << EOM
[google-cloud-cli]
name=Google Cloud CLI
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el8-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOM

yum install -y google-cloud-sdk  
EOT
}

resource "aws_iam_role" "role" {
  name               = "role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "profile" {
  name = "profile"
  role = aws_iam_role.role.name
}

resource "aws_security_group" "bastion_security_group" {
  name        = "bastion-sg"
  description = "Bastion security group"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "local_file" "private_key_openssh_file" {
  content         = tls_private_key.key_pair.private_key_openssh
  filename        = "${path.module}/id_rsa"
  file_permission = "0600"
}
