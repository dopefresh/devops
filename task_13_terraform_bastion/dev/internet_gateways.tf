resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.vasilii-vpc.id
  tags = {
    "Name" = "default igw for vasilii vpc"
  }
}