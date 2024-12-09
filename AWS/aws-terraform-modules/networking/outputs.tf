output "VPC_ID" {
  value = aws_vpc.vpc.id
}

output "PUB_SUBNET_IDS" {
  value = [for subnet in aws_subnet.pub_subnet : subnet.id]
}
output "PRIV_SUBNET_IDS" {
  value = [for subnet in aws_subnet.priv_subnet : subnet.id]
}
output "DEFAULT_SG_ID" {
  value = aws_vpc.vpc.default_security_group_id
}
output "SG_ID" {
  value = aws_security_group.allow_core_icap_mdss.id
}
