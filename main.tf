#############################################################
# PROVIDER CONFIG
#############################################################

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

#############################################################
# VARIABLES
#############################################################

variable "aws_region" {}
variable "project_name" {}
variable "environment" {}

variable "vpc_cidr" {}

variable "public_subnet_1_cidr" {}
variable "public_subnet_2_cidr" {}
variable "private_subnet_1_cidr" {}
variable "private_subnet_2_cidr" {}

variable "availability_zone_1" {}
variable "availability_zone_2" {}

variable "instance_type" {}
variable "ami_id" {}
variable "key_pair_name" {}

variable "root_volume_size" { type = number }
variable "root_volume_type" {}

variable "allowed_ssh_cidr" {}

variable "tags" {
  type    = map(string)
  default = {}
}

#############################################################
# LOCALS
#############################################################

locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = merge({
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }, var.tags)
}

#############################################################
# VPC
#############################################################

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${local.name_prefix}-vpc"
  }
}

#############################################################
# INTERNET GATEWAY
#############################################################

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.name_prefix}-igw"
  }
}

#############################################################
# PUBLIC SUBNETS
#############################################################

resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_1_cidr
  availability_zone      = var.availability_zone_1
  map_public_ip_on_launch = true

  tags = { Name = "${local.name_prefix}-public-1" }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_2_cidr
  availability_zone      = var.availability_zone_2
  map_public_ip_on_launch = true

  tags = { Name = "${local.name_prefix}-public-2" }
}

#############################################################
# PRIVATE SUBNETS
#############################################################

resource "aws_subnet" "private_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_1_cidr
  availability_zone      = var.availability_zone_1
  map_public_ip_on_launch = false

  tags = { Name = "${local.name_prefix}-private-1" }
}

resource "aws_subnet" "private_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_2_cidr
  availability_zone      = var.availability_zone_2
  map_public_ip_on_launch = false

  tags = { Name = "${local.name_prefix}-private-2" }
}

#############################################################
# EIP + NAT GATEWAY
#############################################################

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = { Name = "${local.name_prefix}-eip" }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_1.id

  depends_on = [aws_internet_gateway.igw]

  tags = { Name = "${local.name_prefix}-nat" }
}

#############################################################
# ROUTE TABLES
#############################################################

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "${local.name_prefix}-public-rt" }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = { Name = "${local.name_prefix}-private-rt" }
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private.id
}

#############################################################
# SECURITY GROUPS
#############################################################

resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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

resource "aws_security_group" "ec2_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#############################################################
# IAM ROLE (SSM)
#############################################################

resource "aws_iam_role" "ec2_role" {
  name = "${local.name_prefix}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "profile" {
  role = aws_iam_role.ec2_role.name
}

#############################################################
# EC2 INSTANCE
#############################################################

resource "aws_instance" "web" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private_1.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.profile.name

  associate_public_ip_address = false

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = var.root_volume_type
  }

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install nginx -y
    systemctl enable nginx
    systemctl start nginx
    echo "<h1>Terraform AWS App Running 🚀</h1>" > /var/www/html/index.html
  EOF

  tags = {
    Name = "${local.name_prefix}-ec2"
  }
}

#############################################################
# LOAD BALANCER
#############################################################

resource "aws_lb" "app" {
  name               = "${local.name_prefix}-alb"
  load_balancer_type = "application"
  subnets            = [aws_subnet.public_1.id, aws_subnet.public_2.id]
  security_groups    = [aws_security_group.alb_sg.id]
}

resource "aws_lb_target_group" "tg" {
  name     = "${local.name_prefix}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path = "/"
  }
}

resource "aws_lb_target_group_attachment" "attach" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.web.id
  port             = 80
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

#############################################################
# OUTPUTS
#############################################################

output "alb_dns" {
  value = aws_lb.app.dns_name
}