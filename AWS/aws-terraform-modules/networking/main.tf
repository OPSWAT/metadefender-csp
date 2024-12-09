######### NETWORKING  #########
resource "aws_vpc" "vpc" {
  cidr_block           = var.VPC_CIDR
  enable_dns_hostnames = true

  tags = {
    Name        = "terraform-${var.ENV_NAME}/VPC"
    Environment = terraform.workspace
  }
}

data "aws_availability_zones" "all" {}

resource "aws_subnet" "pub_subnet" {
  count = length(data.aws_availability_zones.all.names)

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(aws_vpc.vpc.cidr_block, 3, count.index)
  availability_zone       = data.aws_availability_zones.all.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name                                           = "terraform-${var.ENV_NAME}/SubnetPublic${data.aws_availability_zones.all.names[count.index]}"
    Environment                                    = terraform.workspace
  }
}

resource "aws_subnet" "priv_subnet" {
  count = length(data.aws_availability_zones.all.names)

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(aws_vpc.vpc.cidr_block, 3, count.index + length(data.aws_availability_zones.all.names))
  availability_zone       = data.aws_availability_zones.all.names[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name          = "terraform-${var.ENV_NAME}/SubnetPrivate${data.aws_availability_zones.all.names[count.index]}"
    Environment   = terraform.workspace
  }
}

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "terraform-${var.ENV_NAME}/InternetGateway"
  }
}

resource "aws_eip" "nat_eip" {
  tags = {
    Name = "terraform-${var.ENV_NAME}/NATIP"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.pub_subnet[0].id
  tags = {
    Name = "terraform-${var.ENV_NAME}/NATGateway"
  }
  depends_on = [
    aws_internet_gateway.ig
  ]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig.id
  }
  tags = {
    Name = "terraform-${var.ENV_NAME}/PublicRouteTable"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = {
    Name = "terraform-${var.ENV_NAME}/PrivateRouteTable"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(data.aws_availability_zones.all.names)
  subnet_id      = element(aws_subnet.pub_subnet.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(data.aws_availability_zones.all.names)
  subnet_id      = element(aws_subnet.priv_subnet.*.id, count.index)
  route_table_id = aws_route_table.private.id
}



#### SECURITY GROUPS FOR METADEFENDER PRODUCTS ####


resource "aws_security_group" "allow_core_icap_mdss" {
  name        = "allow_core_icap_mdss"
  description = "Allow inbound traffic and all outbound traffic for Core and ICAP"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "allow_core_icap_mdss"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_core_port" {
  security_group_id = aws_security_group.allow_core_icap_mdss.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8008
  ip_protocol       = "TCP"
  to_port           = 8008
}

resource "aws_vpc_security_group_ingress_rule" "allow_icap_port" {
  security_group_id = aws_security_group.allow_core_icap_mdss.id
  count             = var.DEPLOY_ICAP == true ? 1 : 0
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8048
  ip_protocol       = "TCP"
  to_port           = 8048
}

resource "aws_vpc_security_group_ingress_rule" "allow_icap_port_2" {
  count             = var.DEPLOY_ICAP == true ? 1 : 0
  security_group_id = aws_security_group.allow_core_icap_mdss.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 1344
  ip_protocol       = "TCP"
  to_port           = 1344
}

resource "aws_vpc_security_group_ingress_rule" "allow_mdss_port" {
  count             = var.DEPLOY_MDSS == true ? 1 : 0
  security_group_id = aws_security_group.allow_core_icap_mdss.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "TCP"
  to_port           = 80
}
resource "aws_vpc_security_group_ingress_rule" "allow_amazonmq_port" {
  count             = var.DEPLOY_MDSS_AMAZONMQ == true ? 1 : 0
  security_group_id = aws_security_group.allow_core_icap_mdss.id
  cidr_ipv4         = var.VPC_CIDR
  from_port         = 5671
  ip_protocol       = "TCP"
  to_port           = 5671
}
resource "aws_vpc_security_group_ingress_rule" "allow_documentdb_port" {
  count             = var.DEPLOY_MDSS_DOCUMENTDB == true ? 1 : 0
  security_group_id = aws_security_group.allow_core_icap_mdss.id
  cidr_ipv4         = var.VPC_CIDR
  from_port         = 27017
  ip_protocol       = "TCP"
  to_port           = 27017
}
resource "aws_vpc_security_group_ingress_rule" "allow_elasticache_port" {
  count             = var.DEPLOY_MDSS_ELASTICACHE == true ? 1 : 0
  security_group_id = aws_security_group.allow_core_icap_mdss.id
  cidr_ipv4         = var.VPC_CIDR
  from_port         = 6379
  ip_protocol       = "TCP"
  to_port           = 6379
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.allow_core_icap_mdss.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 0
  ip_protocol       = "TCP"
  to_port           = 22
}
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_core_icap_mdss.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}