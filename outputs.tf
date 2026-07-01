#############################################################
# outputs.tf
#
# Purpose:
# - Display important infrastructure details after deploy
# - Useful for accessing ALB, VPC, and EC2 info
#############################################################

#############################################################
# APPLICATION LOAD BALANCER URL
#############################################################

output "application_url" {

  description = "Public URL of the Application Load Balancer"

  value = "http://${aws_lb.app_alb.dns_name}"

}

#############################################################
# LOAD BALANCER DNS NAME
#############################################################

output "alb_dns_name" {

  description = "DNS name of the Application Load Balancer"

  value = aws_lb.app_alb.dns_name

}

#############################################################
# VPC ID
#############################################################

output "vpc_id" {

  description = "ID of the VPC"

  value = aws_vpc.main.id

}

#############################################################
# PUBLIC SUBNET IDS
#############################################################

output "public_subnet_ids" {

  description = "List of public subnet IDs"

  value = [
    aws_subnet.public_1.id,
    aws_subnet.public_2.id
  ]

}

#############################################################
# PRIVATE SUBNET IDS
#############################################################

output "private_subnet_ids" {

  description = "List of private subnet IDs"

  value = [
    aws_subnet.private_1.id,
    aws_subnet.private_2.id
  ]

}

#############################################################
# NAT GATEWAY ID
#############################################################

output "nat_gateway_id" {

  description = "ID of the NAT Gateway"

  value = aws_nat_gateway.nat.id

}

#############################################################
# EC2 PRIVATE IP
#############################################################

output "ec2_private_ip" {

  description = "Private IP of the EC2 instance"

  value = aws_instance.web.private_ip

}

#############################################################
# SECURITY GROUPS
#############################################################

output "alb_security_group_id" {

  description = "Security Group ID of ALB"

  value = aws_security_group.alb_sg.id

}

output "ec2_security_group_id" {

  description = "Security Group ID of EC2"

  value = aws_security_group.ec2_sg.id

}