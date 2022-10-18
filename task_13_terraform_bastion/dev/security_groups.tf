resource "aws_security_group" "vasilii-vpc-default-security-group" {
  name = "vasilii-vpc-default-security-group"
  vpc_id = aws_vpc.vasilii-vpc.id
  
  ingress {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "Allow access from internet"
    from_port = 0
    protocol = "-1"
    to_port = 0
  }

  egress {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "Allow internet access"
    from_port = 0
    protocol = "-1"
    to_port = 0
  }

  tags = {
      Name = "vasilii-vpc-default-security-group"
  }
}