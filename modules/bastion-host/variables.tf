variable "vpc_id" {
    type = string
    description = "VPC ID"
}

variable "env" {
    type = string
    description = "Environment"
}

variable "ami_id" {
    type = string
    description = "AMI ID"
}

variable "sn_id" {
    type = string
    description = "Subnet ID"
}

variable "instances_sg" {
    type = set(string)
    description = "Security groups of all instances within the VPC"
}

variable "trusted_host" {
    type = string
    description = "Trusted host"
}