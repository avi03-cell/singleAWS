#############################################################
# terraform.tfvars
#
# Purpose:
# - Define environment-specific values
# - Used by variables.tf
#############################################################

#############################################################
# AWS REGION
#############################################################

aws_region = "ap-south-1"

#############################################################
# PROJECT CONFIGURATION
#############################################################

project_name = "aws-project"
environment  = "dev"

#############################################################
# NETWORKING (VPC + SUBNETS)
#############################################################

vpc_cidr = "10.20.0.0/16"

public_subnet_1_cidr  = "10.20.1.0/24"
public_subnet_2_cidr  = "10.20.2.0/24"

private_subnet_1_cidr = "10.20.11.0/24"
private_subnet_2_cidr = "10.20.12.0/24"

#############################################################
# AVAILABILITY ZONES
#############################################################

availability_zone_1 = "ap-south-1a"
availability_zone_2 = "ap-south-1b"

#############################################################
# EC2 CONFIGURATION
#############################################################

instance_type = "t3.micro"

# Ubuntu 22.04 AMI (update if region changes)
ami_id = "ami-0f5ee92e2d63afc18"

key_pair_name = "my-keypair"

#############################################################
# STORAGE (EBS ROOT VOLUME)
#############################################################

root_volume_size = 20
root_volume_type = "gp3"

#############################################################
# SECURITY (SSH ACCESS)
#############################################################

# IMPORTANT:
# Replace this with YOUR public IP for safety
allowed_ssh_cidr = "0.0.0.0/0"

#############################################################
# ADDITIONAL TAGS
#############################################################

tags = {
  Owner     = "Avibgmi"
  Project   = "AWS VPC ALB EC2 Architecture"
  ManagedBy = "Terraform"
}