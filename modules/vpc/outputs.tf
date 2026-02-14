output "vpc" {
    value = aws_vpc.vpc
}

output "gw" {
    value = aws_internet_gateway.gateway
}

output "sn" {
    value = aws_subnet.subnet
}

output "private_sn" {
    value = [ for index, subnet in aws_subnet.subnet : subnet if !var.config.sn[index] ]
}

output "public_sn" {
    value = [ for index, subnet in aws_subnet.subnet : subnet if var.config.sn[index] ]
}