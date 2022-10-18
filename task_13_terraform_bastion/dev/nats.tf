resource "aws_nat_gateway" "vasilii-vpc-public-subnet-nat" {
  allocation_id = aws_eip.vasilii-vpc-public-subnet-nat-elastic-ip.allocation_id
  subnet_id     = aws_subnet.vasilii-vpc-public-subnet.id
  connectivity_type = "public"

  tags = {
    Name = "vasilii-vpc-public-subnet-nat"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.default]
}