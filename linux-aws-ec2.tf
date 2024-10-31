resource "aws_instance" "aws_private_linux" {
  ami               = "ami-09ee0944866c73f62"
  instance_type     = "t2.micro"
  availability_zone = "eu-west-2b"
  key_name          = "boundary"


  network_interface {
    network_interface_id = aws_network_interface.aws_private_linux_ni.id
    device_index         = 0
  }
  tags = {
    Name         = "boundary-1-dev",
    service-type = "database",
    application  = "dev",
  }
}

resource "aws_network_interface" "aws_private_linux_ni" {
  subnet_id               = aws_subnet.private_subnet.id
  security_groups         = [aws_security_group.static_target_sg.id]
  private_ip_list_enabled = false
}
