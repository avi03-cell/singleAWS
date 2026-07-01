#############################################################
# security_groups.tf
#
# Purpose:
# - Security Group for Application Load Balancer (public)
# - Security Group for EC2 (private)
# - Restrict access using least privilege model
#############################################################

#############################################################
# SECURITY GROUP: APPLICATION LOAD BALANCER
#############################################################

resource "aws_security_group" "alb_sg" {

  name        = "${local.name_prefix}-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  ###########################################################
  # Inbound: HTTP (80)
  ###########################################################

  ingress {
    description = "Allow HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ###########################################################
  # Inbound: HTTPS (443)
  ###########################################################

  ingress {
    description = "Allow HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ###########################################################
  # Outbound: to EC2
  ###########################################################

  egress {
    description = "Allow all outbound traffic to private EC2"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}-alb-sg"
  }

}

#############################################################
# SECURITY GROUP: EC2 (PRIVATE INSTANCE)
#############################################################

resource "aws_security_group" "ec2_sg" {

  name        = "${local.name_prefix}-ec2-sg"
  description = "Security group for private EC2 instance"
  vpc_id      = aws_vpc.main.id

  ###########################################################
  # Inbound: Allow traffic ONLY from ALB
  ###########################################################

  ingress {
    description     = "Allow HTTP from ALB only"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ###########################################################
  # Optional: SSH access (ONLY for debugging via bastion or VPN)
  ###########################################################

  ingress {
    description = "Allow SSH from allowed CIDR"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ###########################################################
  # Outbound: allow all (needed for NAT Gateway access)
  ###########################################################

  egress {
    description = "Allow all outbound traffic (NAT access)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}-ec2-sg"
  }

}