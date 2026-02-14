locals {
  sn = concat(var.subnets[*].public, [true])
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
    region = var.region 
}

module "vpc" {
    source = "./modules/vpc"
    config = {
        cidr_block = var.cidr_block
        env = var.environment
        sn = local.sn
        cidr_block_sn = var.cidr_block_sn
    }
}

module "routes" {
    source = "./modules/routes"
    public_sn_id = module.vpc.public_sn[*].id
    ig_id = module.vpc.gw.id
    env = var.environment
    vpc_id = module.vpc.vpc.id
    vpc_cidr = var.cidr_block
}

module "instances" {
    source = "./modules/instances"
    env = var.environment
    vpc_id = module.vpc.vpc.id
    instances = flatten([ 
      for index, sn in var.subnets : [
        for instance in sn.instances : merge(instance, { sn = module.vpc.sn[index].id })
      ]
    ])
    ami_id = data.aws_ami.ubuntu.id
    key_pair = var.key_pair
}

locals {
  sn_count = length(module.vpc.sn)
  bastion_sn_id = local.sn_count > 0 ? module.vpc.sn[local.sn_count - 1].id : null
}

module "bastion_host" {
  source = "./modules/bastion-host"
  env = var.environment
  vpc_id = module.vpc.vpc.id
  ami_id = data.aws_ami.ubuntu.id
  sn_id = local.bastion_sn_id
  trusted_host = var.trusted_host
  instances_sg = module.instances.sg
  key_pair = var.key_pair
}