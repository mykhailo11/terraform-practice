variable "region" {
    type = string
    description = "VPC region"
}

variable "cidr_block" {
    type = string
    description = "CIDR VPC block"
}

variable "environment" {
    type = string
    description = "Environment"
}

variable "cidr_block_sn" {
  type = string
  description = "Subnet CIDR block template"
}

variable "subnets" {
  type = list(object({
    public = bool
    instances = list(object({
      name = string
      stopped = optional(bool)
      fw = list(object({
        ingress = bool
        ref = optional(string)
        cidr_block = optional(string)
        to_port = number
        from_port = number
        ip_protocol = string
      }))
    }))
  }))
}

variable "trusted_host" {
    type = string
    description = "Trusted host"
}