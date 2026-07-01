#############################################################
# iam.tf
#
# Purpose:
# - IAM Role for EC2 instance
# - Attach AWS managed policies (SSM access)
# - Create instance profile for EC2
#############################################################

#############################################################
# IAM ROLE (for EC2)
#############################################################

resource "aws_iam_role" "ec2_role" {

  name = local.iam_role_name

  ###########################################################
  # Trust Policy (EC2 can assume this role)
  ###########################################################

  assume_role_policy = jsonencode({

    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]

  })

  tags = {
    Name = local.iam_role_name
  }

}

#############################################################
# IAM POLICY ATTACHMENT: SSM MANAGED INSTANCE CORE
#############################################################

resource "aws_iam_role_policy_attachment" "ssm_core" {

  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"

}

#############################################################
# (OPTIONAL) CLOUDWATCH LOGS ACCESS
#############################################################

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {

  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"

}

#############################################################
# INSTANCE PROFILE (required by EC2)
#############################################################

resource "aws_iam_instance_profile" "ec2_profile" {

  name = local.instance_profile_name

  role = aws_iam_role.ec2_role.name

}