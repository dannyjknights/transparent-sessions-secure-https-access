#AWS resource to create the Private VPC CIDR Block and to enable a DNS hostname to the instances
resource "aws_vpc" "boundary_host_vpc" {
  cidr_block           = var.private_vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "Boundary Private Target Network"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.boundary_host_vpc.id
  cidr_block              = var.private_subnet_cidr
  map_public_ip_on_launch = false
  availability_zone       = var.availability_zone
  tags = {
    Name = "Private 192 for Boundary Targets"
  }
}

#AWS resource to create the route table with a default route
resource "aws_route_table" "boundary_host_rt" {
  vpc_id = aws_vpc.boundary_host_vpc.id
  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.boundary_tgw.id
  }
  tags = {
    Name = "boundary-host-rt"
  }
  depends_on = [aws_ec2_transit_gateway.boundary_tgw]
}

#AWS resource to associate the route table to the CIDR block created
resource "aws_route_table_association" "boundary_target_rt_associate" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.boundary_host_rt.id
}

