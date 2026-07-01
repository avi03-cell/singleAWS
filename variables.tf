#############################################################
# variables.tf
#
# Purpose:
# Define all input variables used throughout the Terraform
# project.
#############################################################

#############################################################
# AWS Configuration
#############################################################

variable "aws_region" {
  description = "AWS region where resources will be created."
  type        = string
}

#############################################################
# Project Configuration
#############################################################

variable "project_name" {
  description = "Project name used for naming resources."
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, test, prod)."
  type        = string
}

#############################################################
# Networking
#############################################################

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "public_subnet_1_cidr" {
  description = "CIDR block for Public Subnet 1."
  type        = string
}

variable "public_subnet_2_cidr" {
  description = "CIDR block for Public Subnet 2."
  type        = string
}

variable "private_subnet_1_cidr" {
  description = "CIDR block for Private Subnet 1."
  type        = string
}

variable "private_subnet_2_cidr" {
  description = "CIDR block for Private Subnet 2."
  type        = string
}

#############################################################
# Availability Zones
#############################################################

variable "availability_zone_1" {
  description = "First Availability Zone."
  type        = string
}

variable "availability_zone_2" {
  description = "Second Availability Zone."
  type        = string
}

#############################################################
# EC2 Configuration
#############################################################

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
}

variable "ami_id" {
  description = "Ubuntu AMI ID."
  type        = string
}

variable "key_pair_name" {
  description = "Existing EC2 Key Pair name."
  type        = string
}

#############################################################
# Root Volume
#############################################################

variable "root_volume_size" {
  description = "Root EBS volume size (GB)."
  type        = number
}

variable "root_volume_type" {
  description = "Root EBS volume type."
  type        = string
}

#############################################################
# SSH Access
#############################################################

variable "allowed_ssh_cidr" {
  description = "CIDR allowed to SSH to the EC2 instance."
  type        = string
}

#############################################################
# Application
#############################################################

variable "application_port" {
  description = "Port on which Nginx serves the application."
  type        = number
  default     = 80
}

#############################################################
# Tags
#############################################################

variable "tags" {
  description = "Additional tags applied to all resources."

  type = map(string)

  default = {}
}

variable "domain_name" {
  description = "Your custom domain name (e.g. example.com)"
  type        = string
}


