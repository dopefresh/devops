resource "aws_route_table" "vasilii-vpc-public-subnet-route-table" {
  vpc_id = aws_vpc.vasilii-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }

  tags = {
    Name = "vasilii-vpc-public-subnet-route-table"
  }
}

resource "aws_route_table" "vasilii-vpc-private-subnet-route-table" {
  vpc_id = aws_vpc.vasilii-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.vasilii-vpc-public-subnet-nat.id
  }

  tags = {
    Name = "vasilii-vpc-private-subnet-route-table"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.vasilii-vpc-public-subnet.id
  route_table_id = aws_route_table.vasilii-vpc-public-subnet-route-table.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.vasilii-vpc-private-subnet.id
  route_table_id = aws_route_table.vasilii-vpc-private-subnet-route-table.id
}
