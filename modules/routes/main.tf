resource "aws_route_table" "public_rt" {
    vpc_id = var.vpc_id

    tags = {
        Name = "default-route"
        Environment = var.env
    }
}

resource "aws_route" "ig_route" {
    route_table_id = aws_route_table.public_rt.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = var.ig_id
}

resource "aws_route_table_association" "association" {
    count = length(var.public_sn_id)
    route_table_id = aws_route_table.public_rt.id
    subnet_id = var.public_sn_id[count.index]
}