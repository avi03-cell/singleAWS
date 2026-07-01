#############################################################
# network.tf (PART 1)
#
# Purpose:
# - Create VPC
# - Create Internet Gateway
# - Create Public Subnets
# - Create Private Subnets
#############################################################

#############################################################
# VPC
#############################################################

resource "aws_vpc" "main" {

  cidr_block = var.vpc_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = local.vpc_name
  }

}

#############################################################
# Internet Gateway
#############################################################

resource "aws_internet_gateway" "igw" {

  vpc_id = aws_vpc.main.id

  tags = {
    Name = local.internet_gateway_name
  }

}

#############################################################
# PUBLIC SUBNET 1
#############################################################

resource "aws_subnet" "public_1" {

  vpc_id = aws_vpc.main.id

  cidr_block = var.public_subnet_1_cidr

  availability_zone = var.availability_zone_1

  map_public_ip_on_launch = true

  tags = {
    Name = local.public_subnet_1_name
  }

}

#############################################################
# PUBLIC SUBNET 2
#############################################################

resource "aws_subnet" "public_2" {

  vpc_id = aws_vpc.main.id

  cidr_block = var.public_subnet_2_cidr

  availability_zone = var.availability_zone_2

  map_public_ip_on_launch = true

  tags = {
    Name = local.public_subnet_2_name
  }

}

#############################################################
# PRIVATE SUBNET 1
#############################################################

resource "aws_subnet" "private_1" {

  vpc_id = aws_vpc.main.id

  cidr_block = var.private_subnet_1_cidr

  availability_zone = var.availability_zone_1

  map_public_ip_on_launch = false

  tags = {
    Name = local.private_subnet_1_name
  }

}

#############################################################
# PRIVATE SUBNET 2
#############################################################

resource "aws_subnet" "private_2" {

  vpc_id = aws_vpc.main.id

  cidr_block = var.private_subnet_2_cidr

  availability_zone = var.availability_zone_2

  map_public_ip_on_launch = false

  tags = {
    Name = local.private_subnet_2_name
  }

}
#############################################################
# network.tf (PART 2)
#
# Purpose:
# - Elastic IP for NAT Gateway
# - NAT Gateway (for private subnet outbound internet access)
# - Route Tables (public + private)
# - Routes
# - Subnet associations
#############################################################

#############################################################
# ELASTIC IP (for NAT Gateway)
#############################################################

resource "aws_eip" "nat" {

  domain = "vpc"

  tags = {
    Name = local.eip_name
  }

}

#############################################################
# NAT GATEWAY
#############################################################

resource "aws_nat_gateway" "nat" {

  allocation_id = aws_eip.nat.id

  # NAT Gateway must be in a PUBLIC subnet
  subnet_id = aws_subnet.public_1.id

  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = local.nat_gateway_name
  }

}

#############################################################
# PUBLIC ROUTE TABLE
#############################################################

resource "aws_route_table" "public_rt" {

  vpc_id = aws_vpc.main.id

  tags = {
    Name = local.public_route_table_name
  }

}

#############################################################
# PUBLIC ROUTE (Internet access via IGW)
#############################################################

resource "aws_route" "public_internet_route" {

  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id

}

#############################################################
# ASSOCIATE PUBLIC SUBNET 1
#############################################################

resource "aws_route_table_association" "public_1" {

  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public_rt.id

}

#############################################################
# ASSOCIATE PUBLIC SUBNET 2
#############################################################

resource "aws_route_table_association" "public_2" {

  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public_rt.id

}

#############################################################
# PRIVATE ROUTE TABLE
#############################################################

resource "aws_route_table" "private_rt" {

  vpc_id = aws_vpc.main.id

  tags = {
    Name = local.private_route_table_name
  }

}

#############################################################
# PRIVATE ROUTE (Internet access via NAT Gateway)
#############################################################

resource "aws_route" "private_nat_route" {

  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id

}

#############################################################
# ASSOCIATE PRIVATE SUBNET 1
#############################################################

resource "aws_route_table_association" "private_1" {

  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private_rt.id

}

#############################################################
# ASSOCIATE PRIVATE SUBNET 2
#############################################################

resource "aws_route_table_association" "private_2" {

  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private_rt.id

}