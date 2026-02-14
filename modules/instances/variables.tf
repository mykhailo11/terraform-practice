variable "instances" {
    type = list(object({
        name = string
        stopped = bool
        fw = list(object({
            ingress = bool
            ref = optional(string)
            cidr_block = optional(string)
            to_port = number
            from_port = number
            ip_protocol = string
        }))
        sn = string
    }))
}

variable "vpc_id" {
    type = string
}

variable "env" {
    type = string
    description = "Environment"
}

variable "ami_id" {
    type = string
    description = "AMI ID used for instances"
}

variable "key_pair" {
    type = string
    description = "Key pair"
}