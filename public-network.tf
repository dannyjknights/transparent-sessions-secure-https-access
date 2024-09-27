#AWS resource to create a VPC CIDR Block and to enable a DNS hostname to the instances
resource "aws_vpc" "boundary_ingress_worker_vpc" {
  cidr_block           = var.aws_vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "Boundary Ingress Worker Public VPC CIDR Block"
  }
}

# Create a Public subnet and assign to the VPC. The NAT gateway will be associated to this subnet
resource "aws_subnet" "boundary_ingress_worker_subnet" {
  vpc_id                  = aws_vpc.boundary_ingress_worker_vpc.id
  cidr_block              = var.aws_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone
  tags = {
    Name = "Boundary Ingress Worker Public Subnet"
  }
}

# Create a Private subnet and assign to the VPC.
resource "aws_subnet" "boundary_private_ingress_worker_subnet" {
  vpc_id                  = aws_vpc.boundary_ingress_worker_vpc.id
  cidr_block              = "172.31.40.0/24"
  map_public_ip_on_launch = false
  availability_zone       = var.availability_zone
  tags = {
    Name = "Boundary Ingress Worker Private Subnet"
  }
}

# AWS resource to create the Internet Gateway
resource "aws_internet_gateway" "boundary_ingress_worker_ig" {
  vpc_id = aws_vpc.boundary_ingress_worker_vpc.id
  tags = {
    Name = "boundary-worker-igw"
  }
}

/* AWS resource to create a route table with a default route pointing to the IGW and
a route for the private 192.x.x.x network pointing towards the TGW
*/
resource "aws_route_table" "boundary_ingress_worker_public_rt" {
  vpc_id = aws_vpc.boundary_ingress_worker_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.boundary_ingress_worker_ig.id
  }
  route {
    cidr_block         = "192.168.0.0/24"
    transit_gateway_id = aws_ec2_transit_gateway.boundary_tgw.id
  }
  tags = {
    Name = "boundary-ingress-worker-public-rt"
  }
  depends_on = [aws_ec2_transit_gateway.boundary_tgw]
}

/* AWS resource to create a route table with a default route pointing to the NAT GW and
a route for the private 192.x.x.x network pointing towards the TGW
*/
resource "aws_route_table" "boundary_ingress_worker_private_rt" {
  vpc_id = aws_vpc.boundary_ingress_worker_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
  route {
    cidr_block         = "192.168.0.0/24"
    transit_gateway_id = aws_ec2_transit_gateway.boundary_tgw.id
  }
  tags = {
    Name = "boundary-ingress-worker-private-rt"
  }
  depends_on = [aws_ec2_transit_gateway.boundary_tgw]
}

# AWS resource to associate the route table to the CIDR blocks created
resource "aws_route_table_association" "boundary_ingress_worker_public_rt_associate" {
  subnet_id      = aws_subnet.boundary_ingress_worker_subnet.id
  route_table_id = aws_route_table.boundary_ingress_worker_public_rt.id
}

resource "aws_route_table_association" "boundary_ingress_worker_private_rt_associate" {
  subnet_id      = aws_subnet.boundary_private_ingress_worker_subnet.id
  route_table_id = aws_route_table.boundary_ingress_worker_private_rt.id
}