resource "aws_instance" "vasilii-vpc-public-subnet-bastion-host" {
    instance_type = "t2.micro"
    ami = var.hosts_ami
    subnet_id = aws_subnet.vasilii-vpc-public-subnet.id
    key_name = aws_key_pair.vasilii-vpc-default-ec2-keypair.key_name
    associate_public_ip_address = true
    vpc_security_group_ids = [ aws_security_group.vasilii-vpc-default-security-group.id ]

    tags = {
      "Name" = "vasilii-vpc-public-subnet-bastion-host"
    }
}

resource "aws_instance" "vasilii-vpc-private-subnet-host" {
    instance_type = "t2.micro"
    ami = var.hosts_ami
    subnet_id = aws_subnet.vasilii-vpc-private-subnet.id
    key_name = aws_key_pair.vasilii-vpc-default-ec2-keypair.key_name
    vpc_security_group_ids = [ aws_security_group.vasilii-vpc-default-security-group.id ]

    tags = {
      "Name" = "vasilii-vpc-private-subnet-host"
    }
}