resource "aws_security_group" "web" {

  name = format("%s-web-sg", var.name)
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = var.web_port
    to_port     = var.web_port
    protocol    = "tcp"
    cidr_blocks = module.vpc.public_subnets_cidr_blocks
  }

  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = module.vpc.public_subnets_cidr_blocks
  }

  egress {
    from_port   = "0"
    to_port     = "65535"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Group = var.name
    Name  = "web-sg"
  }

}

resource "aws_launch_configuration" "web" {
  image_id        = data.aws_ami.amazon_linux.id
  instance_type   = var.web_instance_type
  security_groups = [aws_security_group.web.id]

  #TODO REMOVE

  key_name = var.web_key_pair_name
  name_prefix = "${var.name}-web-vm-"

  user_data = <<-EOF
              #!/bin/bash
              sudo yum install -y git
              curl -sL https://rpm.nodesource.com/setup_10.x | sudo bash -
              sudo yum install -y nodejs
              cd ~
              git clone https://github.com/VamshiManikonda/Terraform-3-tire-app.git
              cd Terraform-3-tire-app/sample-web-app/client
              npm install
              npm start 2>&1| tee npm-output.txt
              
              # configure and start nginx
              #export APP_ELB="${module.elb_app.this_elb_dns_name}" APP_PORT="${var.app_port}" WEB_PORT="${var.web_port}"
              #envsubst '$${APP_PORT} $${APP_ELB} $${WEB_PORT}' < nginx.conf.template > /etc/nginx/nginx.conf
              #service nginx start
              EOF

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_autoscaling_group" "web" {
  launch_configuration = aws_launch_configuration.web.id

  vpc_zone_identifier = module.vpc.public_subnets

  load_balancers    = flatten([module.elb_web.this_elb_name])
  health_check_type = "EC2"

  min_size = var.web_autoscale_min_size
  max_size = var.web_autoscale_max_size

  tags = [
  {
    key = "Group"
    value = var.name
    Name = "web-asg-${var.name}"
    propagate_at_launch = true
  }

]
}


