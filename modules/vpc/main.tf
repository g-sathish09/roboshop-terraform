resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  tags = {
    Name = "${var.env}-vpc"
  }
}


resource "aws_subnet" "subnet" {
  for_each   = var.subnets
  vpc_id     = aws_vpc.main.id
  cidr_block = each.value["cidr_block"]
  tags = {
    Name = "${var.env}-${each.key}"
  }
}

resource "aws_vpc_peering_connection" "main" {
  peer_vpc_id = var.default_vpc["id"]
  vpc_id      = aws_vpc.main.id
  auto_accept = true
}

resource "aws_route" "main" {
  route_table_id            = aws_vpc.main.default_route_table_id
  destination_cidr_block    = var.default_vpc["cidr"]
  vpc_peering_connection_id = aws_vpc_peering_connection.main.id
}

resource "aws_route" "default-vpc-route-table" {
  route_table_id            = var.default_vpc["route_table"]
  destination_cidr_block    = var.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.main.id

}

