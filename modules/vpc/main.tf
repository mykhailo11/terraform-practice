data "aws_availability_zones" "az" {
  state = "available"
}

locals {
    az_length = length(data.aws_availability_zones.az.names)
}

resource "aws_vpc" "vpc" {
    cidr_block = var.config.cidr_block

    enable_dns_support = true
    enable_dns_hostnames = true
    tags = {
        Name = "main-vpc"
        Environment = var.config.env
    }
}

resource "aws_internet_gateway" "gateway" {
    vpc_id = aws_vpc.vpc.id
    tags = {
        Name = "main-gateway"
        Environment = var.config.env
    }
}

resource "aws_subnet" "subnet" {
    count = length(var.config.sn)
    vpc_id = aws_vpc.vpc.id
    cidr_block = format(var.config.cidr_block_sn, count.index)
    availability_zone = data.aws_availability_zones.az.names[count.index % local.az_length]
    map_public_ip_on_launch = var.config.sn[count.index]
    tags = {
      Name = "main_vpc_sn_${count.index}"
      Environment = var.config.env
    }
}