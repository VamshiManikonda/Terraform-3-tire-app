resource "aws_security_group" "elb_app" {

  name = format("%s-elb-app-sg", var.name)
  load_balancer_type = "network"

  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks =  module.vpc.public_subnets_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Group = var.name
    Name  = "app-elb-sg"
  }

}

module "elb_app" {
  source = "terraform-aws-modules/elb/aws"

  version = "~> 2.0"
  name = format("%s-elb-app", var.name)

  subnets         = module.vpc.private_subnets
  security_groups = [aws_security_group.elb_app.id]
  internal        = true

  listener = [
    {
      instance_port     = var.app_port
      instance_protocol = "TCP"
      lb_port           = var.app_port
      lb_protocol       = "TCP"
    },
  ]

  health_check = {
      target              = "TCP:${var.app_port}"
      interval            = var.app_elb_health_check_interval
      healthy_threshold   = var.app_elb_healthy_threshold
      unhealthy_threshold = var.app_elb_unhealthy_threshold
      timeout             = var.app_elb_health_check_timeout
    }


  tags = {
    Group = var.name
    Name  = "app-elb-${var.name}"
  }

}



