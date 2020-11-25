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


module "database_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "andre-database-sg"
  description = "security group for database"
  vpc_id      = module.database_vpc.vpc_id

  depends_on = [module.database_vpc]

  #ingress_cidr_blocks      = module.database_vpc.public_subnets_cidr_blocks #ou 10.0.0.0/16
  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "HTTP"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "HTTPS"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "postgres"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}

module "database_vpc" {
  source = "terraform-aws-modules/vpc/aws"


  name            = "andre-vpc-database"
  cidr            = "10.0.0.0/16"
  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"] 
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]


  enable_nat_gateway = true
  single_nat_gateway = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    Name = "andre-db-public-subnet"
  }

  tags = {
    Owner       = "andre"
    Name  = "andre-database-vpc"
  }

  vpc_tags = {
    Name = "andre-vpc-database"
  }

}

module "database" {
  source  = "terraform-aws-modules/rds/aws"

  identifier = "demodb"

  depends_on     = [module.database_sg, data.aws_ami.ubuntu18, module.database_vpc]

  engine            = "postgres"
  engine_version    = "12"
  instance_class    = "db.t2.micro"
  allocated_storage = 5
  storage_encrypted = false

  name     = "tasks"
  username = "cloud"
  password = "cloud123"
  port     = "5432"

  iam_database_authentication_enabled = true

  vpc_security_group_ids = [module.database_sg.this_security_group_id, module.database_vpc.default_security_group_id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # disable backups to create DB faster
  backup_retention_period = 0

  tags = {
    Owner       = "andre"
    Name = "andre-database"
  }

  # DB subnet group
  subnet_ids = [module.database_vpc.public_subnets[0], module.database_vpc.public_subnets[1]] #private subnet?

  # DB parameter group
  family = "postgres12"

  # DB option group
  major_engine_version = "12"

  # Snapshot name upon DB deletion
  final_snapshot_identifier = "demodb"

  # Database Deletion Protection
  deletion_protection = false
  
  publicly_accessible = true


}




