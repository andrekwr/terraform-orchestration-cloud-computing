terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }
}

provider "aws" {
  region = var.region

  access_key = var.access_key
  secret_key = var.secret_key
}

data "aws_availability_zones" "available" {
  state             = "available"
}


data "aws_ami" "ubuntu18" {
  most_recent = true


  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}



module "backend_sg" {
  source = "terraform-aws-modules/security-group/aws"

  depends_on = [module.backend_vpc]

  name        = "andre-backend-sg"
  description = "Security group backend"
  vpc_id      = module.backend_vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "Allow SSH"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "Allow HTTP"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Allow HTTPS"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      description = "Allow server connection"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow all outgoing traffic"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = {
    Owner = "andre"
    Name  = "andre-backend-sg"
  }
}




module "backend_vpc" {
  source = "terraform-aws-modules/vpc/aws"


  name            = "andre-vpc-backend"
  cidr            = "10.0.0.0/16"
  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"] 
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]


  enable_nat_gateway = true
  single_nat_gateway = true


  public_subnet_tags = {
    Name = "andre-db-public-subnet"
  }

  tags = {
    Owner       = "andre"
    Name  = "andre-backend-vpc"
  }

  vpc_tags = {
    Name = "andre-vpc-backend"
  }

}

# Launch configuration
resource "aws_launch_configuration" "lc_asg" {

  depends_on = [module.backend_sg, data.aws_ami.ubuntu18, var.server_depends_on]

  name_prefix   = "andre-lc-asg"
  image_id      = data.aws_ami.ubuntu18.id
  instance_type = "t2.micro"
  security_groups = [module.backend_sg.this_security_group_id]

  key_name = module.key_pair_andre.this_key_pair_key_name

  user_data = data.template_file.django_server_setup.rendered

  lifecycle {
    create_before_destroy = true
  }
}

# Autoscaling group
module "backend_asg" {
  source = "terraform-aws-modules/autoscaling/aws"

  name = "andre-backend-asg"
  depends_on = [module.backend_vpc, module.backend_sg, module.backend_elb, data.aws_ami.ubuntu18]
  # Launch configuration
  #
  launch_configuration = aws_launch_configuration.lc_asg.name # Use the existing launch configuration
  create_lc = false # disables creation of launch configuration
  # lc_name = "example-lc"
  recreate_asg_when_lc_changes = true

  security_groups = [module.backend_sg.this_security_group_id]
  load_balancers  = [module.backend_elb.this_elb_id]

  # Auto scaling group
  asg_name                  = "andre-backend-asg"
  vpc_zone_identifier       = module.backend_vpc.public_subnets
  health_check_type         = "EC2"
  min_size                  = 1
  max_size                  = 3
  desired_capacity          = 1
  wait_for_capacity_timeout = 0

  tags = [
    {
      key                 = "Name"
      value               = "andre-asg"
      propagate_at_launch = true
    },
  ]
}

module "backend_elb" {
  source = "terraform-aws-modules/elb/aws"

  depends_on = [module.backend_vpc, module.backend_sg]
  name = "andre-backend-elb"

  subnets         = module.backend_vpc.public_subnets
  security_groups = [module.backend_sg.this_security_group_id]
  internal        = false


  listener = [
    {
      instance_port     = "8080"
      instance_protocol = "tcp"
      lb_port           = "8080"
      lb_protocol       = "tcp"
    },
  ]


  health_check = {
    target              = "TCP:8080"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 20
  }


  tags = {
    Owner       = "andre"
    Name = "andre-elb"
  }

}

