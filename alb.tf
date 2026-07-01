#############################################################
# alb.tf
#
# Purpose:
# - Create Application Load Balancer (public)
# - Create Target Group
# - Create Listener (HTTP)
# - Attach private EC2 instances
#############################################################

#############################################################
# APPLICATION LOAD BALANCER
#############################################################

resource "aws_lb" "app_alb" {

  name               = local.alb_name
  load_balancer_type = "application"

  # Public ALB → placed in PUBLIC subnets
  subnets = [
    aws_subnet.public_1.id,
    aws_subnet.public_2.id
  ]

  security_groups = [
    aws_security_group.alb_sg.id
  ]

  enable_deletion_protection = false

  tags = {
    Name = local.alb_name
  }

}

#############################################################
# TARGET GROUP
#############################################################

resource "aws_lb_target_group" "app_tg" {

  name     = local.target_group_name
  port     = 80
  protocol = "HTTP"

  vpc_id = aws_vpc.main.id

  ###########################################################
  # Health Check (Nginx)
  ###########################################################

  health_check {

    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2

  }

  tags = {
    Name = local.target_group_name
  }

}

#############################################################
# ATTACH PRIVATE EC2 TO TARGET GROUP
#############################################################

resource "aws_lb_target_group_attachment" "ec2_attach" {

  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.web.id
  port             = 80

}

#############################################################
# LISTENER (HTTP :80)
#############################################################

resource "aws_lb_listener" "http_listener" {

  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  ###########################################################
  # Forward traffic to Target Group
  ###########################################################

  default_action {

    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn

  }

}