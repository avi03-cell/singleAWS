#############################################################
# locals.tf
#
# Purpose:
# - Define reusable values.
# - Generate consistent resource names.
# - Define common tags.
#############################################################

locals {

  ###########################################################
  # Project Naming
  ###########################################################

  name_prefix = "${var.project_name}-${var.environment}"

  ###########################################################
  # Common Tags
  ###########################################################

  common_tags = merge(

    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    },

    var.tags

  )

  ###########################################################
  # Resource Names
  ###########################################################

  vpc_name = "${local.name_prefix}-vpc"

  internet_gateway_name = "${local.name_prefix}-igw"

  nat_gateway_name = "${local.name_prefix}-nat"

  eip_name = "${local.name_prefix}-eip"

  public_route_table_name = "${local.name_prefix}-public-rt"

  private_route_table_name = "${local.name_prefix}-private-rt"

  public_subnet_1_name = "${local.name_prefix}-public-subnet-1"

  public_subnet_2_name = "${local.name_prefix}-public-subnet-2"

  private_subnet_1_name = "${local.name_prefix}-private-subnet-1"

  private_subnet_2_name = "${local.name_prefix}-private-subnet-2"

  alb_name = "${local.name_prefix}-alb"

  target_group_name = "${local.name_prefix}-tg"

  ec2_name = "${local.name_prefix}-web"

  iam_role_name = "${local.name_prefix}-ec2-role"

  instance_profile_name = "${local.name_prefix}-instance-profile"

}