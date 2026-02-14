variable "vpc_id" {
    type = string
    description = "VPC ID"
}

variable "vpc_cidr" {
    type = string
    description = "VPC CIDR"
}

variable "ig_id" {
    type = string
    description = "Internet Gateway ID"
}

variable "env" {
    type = string
    description = "Environment"
}

variable "public_sn_id" {
    type = list(string)
    description = "Public subnets"
}