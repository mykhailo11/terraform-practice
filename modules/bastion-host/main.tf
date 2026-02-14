resource "aws_security_group" "sg" {
    vpc_id = var.vpc_id
    name = "vpc_sg_bastion"
    tags = {
      Name = "vpc_sg_bastion"
      Environment = var.env
    }
}

resource "aws_instance" "bastion" {
    ami = var.ami_id
    instance_type = "t2.micro"
    subnet_id = var.sn_id
    vpc_security_group_ids = [ aws_security_group.sg.id ]
    
    tags = {
      Name = "instance_${each.key}"
      Environment = var.env
    }

}

resource "aws_vpc_security_group_ingress_rule" "bastion_ingress_rule" {
  security_group_id = aws_security_group.sg.id
  from_port = 22
  to_port = 22
  ip_protocol = "tcp"
  cidr_ipv4 = "${var.trusted_host}/32"
}

resource "aws_vpc_security_group_egress_rule" "egress_rule" {
  for_each = var.instances_sg
  security_group_id = aws_security_group.sg.id
  from_port = 22
  to_port = 22
  ip_protocol = "tcp"
  referenced_security_group_id = each.value
}

resource "aws_vpc_security_group_ingress_rule" "ingress_rule" {
  for_each = var.instances_sg
  security_group_id = each.value
  from_port = 22
  to_port = 22
  ip_protocol = "tcp"
  referenced_security_group_id = aws_security_group.sg.id
}

