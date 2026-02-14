variable "config" {
    type = object({
      cidr_block = string
      env = string
      sn = list(bool)
      cidr_block_sn = string
    })
}