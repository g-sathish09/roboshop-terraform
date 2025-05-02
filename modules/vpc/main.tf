resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  tags = {
    Name = "${var.env}-vpc"
  }
}

resource "aws_subnet" "main" {
  for_each          = var.subnets
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value["cidr_block"]
  availability_zone = each.value["az"]
  tags = {
    Name         = "${var.env}-${each.key}"
    subnet_group = each.value["subnet_group"]
  }
}

resource "aws_route_table" "main" {
  for_each = var.subnets
  vpc_id   = aws_vpc.main.id
  tags = {
    Name = "${var.env}-${each.key}"
  }
}

resource "aws_route_table_association" "main" {
  for_each       = var.subnets
  subnet_id      = aws_subnet.main[each.key].id
  route_table_id = aws_route_table.main[each.key].id
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.env}-igw"
  }
}

resource "aws_eip" "igw" {
  count  = length(local.az)
  domain = "vpc"
  tags = {
    Name = "${var.env}-ngw"
  }
}

resource "aws_nat_gateway" "main" {
  count         = length(local.az)
  allocation_id = aws_eip.igw[count.index].id
  subnet_id     = aws_subnet.main[local.igw_enabled_subnets[count.index]].id

  tags = {
    Name = "${var.env}-ngw"
  }
}

resource "aws_route" "igw" {
  count                  = length(local.igw_enabled_subnets)
  route_table_id         = aws_route_table.main[local.igw_enabled_subnets[count.index]].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route" "ngw" {
  count                  = length(local.ngw_enabled_subnets)
  route_table_id         = aws_route_table.main[local.ngw_enabled_subnets[count.index]].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.main.*.id, count.index)
}

resource "aws_vpc_peering_connection" "main" {
  peer_vpc_id = var.default_vpc["id"]
  vpc_id      = aws_vpc.main.id
  auto_accept = true
}

resource "aws_route" "main" {
  for_each                  = var.subnets
  route_table_id            = aws_route_table.main[each.key].id
  destination_cidr_block    = var.default_vpc["cidr"]
  vpc_peering_connection_id = aws_vpc_peering_connection.main.id
}

resource "aws_route" "default-vpc-route-table" {
  route_table_id            = var.default_vpc["route_table"]
  destination_cidr_block    = var.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.main.id
}


