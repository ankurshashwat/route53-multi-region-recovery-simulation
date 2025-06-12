terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket         = "route-53-multi-region-simulation-tf-state"
    key            = "state/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "route-53-multi-region-simulation-tf-lock"
  }
}

provider "aws" {
  region = var.region
}

provider "aws" {
  alias  = "us_west_2"
  region = var.secondary_region
}

module "vpc" {
  source   = "./modules/vpc"
  local_ip = var.local_ip
  region   = var.region
  project  = var.project
}

module "vpc_west" {
  source   = "./modules/vpc"
  local_ip = var.local_ip
  region   = var.secondary_region
  project  = var.project
  providers = {
    aws = aws.us_west_2
  }
}

module "ec2" {
  source           = "./modules/ec2"
  region           = var.region
  vpc_id           = module.vpc.vpc_id
  subnet_id        = module.vpc.public_subnet_ids[0]
  project          = var.project
  github_repo      = var.github_repo
  db_host          = split(":", module.rds.endpoint)[0]
  db_user          = var.db_user
  db_password      = var.db_password
  db_name          = var.db_name
  app_server_sg_id = module.vpc.app_server_sg_id
}

module "ec2_west" {
  source           = "./modules/ec2"
  region           = var.secondary_region
  vpc_id           = module.vpc_west.vpc_id
  subnet_id        = module.vpc_west.public_subnet_ids[0]
  project          = var.project
  github_repo      = var.github_repo
  db_host          = split(":", module.rds.endpoint)[0]
  db_user          = var.db_user
  db_password      = var.db_password
  db_name          = var.db_name
  app_server_sg_id = module.vpc_west.app_server_sg_id
  providers = {
    aws = aws.us_west_2
  }
}

module "rds" {
  source               = "./modules/rds"
  vpc_id               = module.vpc.vpc_id
  secondary_vpc_id     = module.vpc_west.vpc_id
  subnet_ids           = module.vpc.private_subnet_ids
  secondary_subnet_ids = module.vpc_west.private_subnet_ids
  app_server_sg_id     = module.vpc.app_server_sg_id
  app_server_sg_id_west = module.vpc_west.app_server_sg_id
  rds_sg_id            = module.vpc.rds_sg_id
  rds_sg_id_west       = module.vpc_west.rds_sg_id
  project              = var.project
  db_user              = var.db_user
  db_password          = var.db_password
  db_name              = var.db_name
  local_ip             = var.local_ip
  providers = {
    aws           = aws
    aws.us_west_2 = aws.us_west_2
  }
}

module "route53" {
  source                  = "./modules/route53"
  project                 = var.project
  primary_ec2_public_ip   = module.ec2.public_ip
  secondary_ec2_public_ip = module.ec2_west.public_ip
  domain_name             = var.domain_name
}