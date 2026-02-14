# Practicing IaC tools for creating cloud infrastracture

## Tools:
- Terraform
- AWS

## Schema:  
### Subnets:
Infrastructure consists of a VPC with 2 subnets - public and private for testing purposes. The VPC has Internet Gateway attached.\
\
The amount of subnets can be adjusted via corresponding environment terraform variables files, for development default terraform.tfvars is used.\
\
Configuration has the following structure:
```
subnets - list of subnets

    public - whether the subnet is public

    instances - subnet instances if any

        name - name of the instance that can be used as a reference

        stopped - whether the instance should be ignored, existing instances will be deleted

        fw - firewall rules, will be interpreted as security group with any amount of rules

            ingress - if the rule is for inbound requests, otherwise outbound

            cidr_block - optional, allowed IP range

            reference - optional, allowed referenced instance

            from_port / to_port - allowed port range

            ip_protocol - communication protocol

...

```

> Either reference or CIDR block must be specified

Subnets will be automatically assigned on different availability zones based on the VPC region

### Bastion host:

I decided to create all the necessary configuration (subnet, security groups, etc) in a separate module, because as number of instances grow it is important to keep all the rules in one place, calculated dynamically based on the amount of managed units

## Missing functionality
There is still a space for improvements. Among the possible options I see:
- Assign a key pair for public instances in order to have ssh pre-configured
- Replace the rule name. now there is only one ingress / egress rule per instance, but for multiple rules of the same type the latest one may override previous
```
resource "aws_vpc_security_group_ingress_rule" "ingress_ref_sg_rule" {
  for_each = { for index, rule in local.rules : rule["name"] => rule if rule.ingress_ref && contains(keys(aws_security_group.sg), rule["ref"]) }
  ...
```
- Store terraform state on a remote host (either terraform registry or AWS backend)