locals {

  sg_name_template = "vpc_sg_%s"
  instances = { for instance in var.instances : instance.name => instance if instance.stopped == null || !instance.stopped }
  rules = flatten([
    for key, instance in local.instances : [
      for fw in instance.fw : merge(fw, {
        name = key
        ingress_ref = fw.ingress && fw.ref != null
        ingress_cidr = fw.ingress && fw.ref == null
        egress_ref = !fw.ingress && fw.ref != null
        egress_cidr = !fw.ingress && fw.ref == null
      })
    ] if instance.stopped == null || !instance.stopped
  ]) 
  # stopped = [ for instance in var.instances : instance.name if instance.stopped != null && instance.stopped ]
}

resource "aws_security_group" "sg" {
  for_each = local.instances
  vpc_id = var.vpc_id
  name = format(local.sg_name_template, each.key)
  tags = {
    Name = format(local.sg_name_template, each.key)
    Environment = var.env
  }
}

resource "aws_instance" "instance" {
    for_each = local.instances
    ami = var.ami_id
    instance_type = "t2.micro"
    subnet_id = each.value.sn
    vpc_security_group_ids = [ aws_security_group.sg[each.key].id ]

    instance_market_options {
        market_type = "spot"
        spot_options {
            max_price = 0.01
            spot_instance_type = "one-time"
        }
    }

    tags = {
      Name = "instance_${each.key}"
      Environment = var.env
    }
}

# resource "aws_ec2_instance_state" "stopped" {
#   count = length(local.stopped)
#   instance_id = aws_instance.instance[local.stopped[count.index]].id
#   state = "stopped"
# }

// todo
resource "aws_vpc_security_group_ingress_rule" "ingress_ref_sg_rule" {
  for_each = { for index, rule in local.rules : rule["name"] => rule if rule.ingress_ref && contains(keys(aws_security_group.sg), rule["ref"]) }
  security_group_id = aws_security_group.sg[each.value["name"]].id
  from_port = each.value["from_port"]
  to_port = each.value["to_port"]
  ip_protocol = each.value["ip_protocol"]
  referenced_security_group_id = aws_security_group.sg[each.value["ref"]].id
}

resource "aws_vpc_security_group_ingress_rule" "ingress_cidr_sg_rule" {
  for_each = { for rule in local.rules : rule["name"] => rule if rule.ingress_cidr }
  security_group_id = aws_security_group.sg[each.value["name"]].id
  from_port = each.value["from_port"]
  to_port = each.value["to_port"]
  ip_protocol = each.value["ip_protocol"]
  cidr_ipv4 = each.value["cidr_block"]
}

resource "aws_vpc_security_group_egress_rule" "egress_ref_sg_rule" {
  for_each = { for rule in local.rules : rule["name"] => rule if rule.egress_ref && contains(keys(aws_security_group.sg), rule["ref"]) }
  security_group_id = aws_security_group.sg[each.value["name"]].id
  from_port = each.value["from_port"]
  to_port = each.value["to_port"]
  ip_protocol = each.value["ip_protocol"]
  referenced_security_group_id = aws_security_group.sg[each.value["ref"]].id
}

resource "aws_vpc_security_group_egress_rule" "egress_cidr_sg_rule" {
  for_each = { for rule in local.rules : rule["name"] => rule if rule.egress_cidr }
  security_group_id = aws_security_group.sg[each.value["name"]].id
  from_port = each.value["from_port"]
  to_port = each.value["to_port"]
  ip_protocol = each.value["ip_protocol"]
  cidr_ipv4 = each.value["cidr_block"]
}