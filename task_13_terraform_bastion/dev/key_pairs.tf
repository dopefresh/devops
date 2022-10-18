resource "aws_key_pair" "vasilii-vpc-default-ec2-keypair" {
  key_name   = "vasilii-vpc-default-ec2-keypair"
  public_key = var.public_key
}
