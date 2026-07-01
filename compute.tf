#############################################################
# compute.tf
#
# Purpose:
# - Launch EC2 instance in PRIVATE subnet
# - Install and configure Nginx via user data
# - Attach IAM role (for future AWS access)
#############################################################

#############################################################
# EC2 INSTANCE (PRIVATE WEB SERVER)
#############################################################

resource "aws_instance" "web" {

  ami           = var.ami_id
  instance_type = var.instance_type

  ###########################################################
  # Private Subnet placement
  ###########################################################

  subnet_id = aws_subnet.private_1.id

  ###########################################################
  # No public IP (IMPORTANT)
  ###########################################################

  associate_public_ip_address = false

  ###########################################################
  # Security Group
  ###########################################################

  vpc_security_group_ids = [
    aws_security_group.ec2_sg.id
  ]

  ###########################################################
  # IAM Role (defined in iam.tf)
  ###########################################################

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  ###########################################################
  # Root Volume
  ###########################################################

  root_block_device {

    volume_size = var.root_volume_size
    volume_type = var.root_volume_type

  }

  ###########################################################
  # User Data (install and start Nginx)
  ###########################################################

  user_data = file("${path.module}/user-data.sh")

  ###########################################################
  # Tags
  ###########################################################

  tags = {
    Name = local.ec2_name
  }

}