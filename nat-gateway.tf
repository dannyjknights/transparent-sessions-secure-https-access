# Create an Elastic IP resource for the NAT gateway
resource "aws_eip" "nat_gw_ip" {
  vpc = true
}

# Create a NAT gateway resource and attach it to the Elastic IP and a subnet
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_gw_ip.id                         # Use the ID of the Elastic IP resource
  subnet_id     = aws_subnet.boundary_ingress_worker_subnet.id # Use the ID of the subnet to attach the NAT gateway

  tags = {
    Name = "Boundary Demo NAT GW" # Add a name tag to the NAT gateway
  }

  /* Define a dependency to ensure the Internet Gateway is created before the NAT Gateway.
  This is to ensure the networking is correctly setup prior to any workers being deployed that
  then need to reach out to the Internet to download the Boundary Worker binary
  */
  depends_on = [aws_internet_gateway.boundary_ingress_worker_ig]
}

