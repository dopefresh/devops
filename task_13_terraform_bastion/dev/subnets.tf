resource "aws_subnet" "vasilii-vpc-public-subnet" {
    vpc_id = aws_vpc.vasilii-vpc.id
    cidr_block = "172.16.1.0/24"

    tags = {
      "Name" = "vasilii-vpc-public-subnet"
    }
}

resource "aws_subnet" "vasilii-vpc-private-subnet" {
    vpc_id = aws_vpc.vasilii-vpc.id
    cidr_block = "172.16.2.0/24"

    tags = {
      "Name" = "vasilii-vpc-private-subnet"
    }
}