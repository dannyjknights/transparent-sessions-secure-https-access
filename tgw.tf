# Main Route Table Association to force these route tables to be preferred over default
resource "aws_main_route_table_association" "main_rt_public_vpc" {
  vpc_id         = aws_vpc.boundary_ingress_worker_vpc.id
  route_table_id = aws_route_table.boundary_ingress_worker_public_rt.id
}

resource "aws_main_route_table_association" "main_rt_private_vpc" {
  vpc_id         = aws_vpc.boundary_host_vpc.id
  route_table_id = aws_route_table.boundary_host_rt.id
}

# Create a new Transit Gateway
resource "aws_ec2_transit_gateway" "boundary_tgw" {
  description                     = "Bounday TGW"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  tags = {
    Name = "Boundary TGW Deployment"
  }
}

# Create a new VPC attachment for the private 192.x.x.x subnet
resource "aws_ec2_transit_gateway_vpc_attachment" "private_vpc_attachment" {
  subnet_ids                                      = [aws_subnet.private_subnet.id]
  transit_gateway_id                              = aws_ec2_transit_gateway.boundary_tgw.id
  vpc_id                                          = aws_vpc.boundary_host_vpc.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = {
    Name = "Boundary Private VPC TGW Attachment"
  }
}

# Create a new VPC attachment for the Private Ingress Subnet
resource "aws_ec2_transit_gateway_vpc_attachment" "public_vpc_attachment" {
  subnet_ids                                      = [aws_subnet.boundary_private_ingress_worker_subnet.id]
  transit_gateway_id                              = aws_ec2_transit_gateway.boundary_tgw.id
  vpc_id                                          = aws_vpc.boundary_ingress_worker_vpc.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = {
    Name = "Boundary Public VPC TGW Attachment"
  }
}

# Create a route table for the TGW
resource "aws_ec2_transit_gateway_route_table" "tgw_rt" {
  transit_gateway_id = aws_ec2_transit_gateway.boundary_tgw.id
  tags = {
    Name = "TGW VPC Route Table"
  }
}

# Specify a static default route in the TGW route table pointing towards the public VPC
resource "aws_ec2_transit_gateway_route" "tgw_default_route" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.public_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_rt.id
}

# Associate the private VPC to the TGW route table
resource "aws_ec2_transit_gateway_route_table_association" "private_vpc_to_public_vpc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.private_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_rt.id
}

# Associate the public VPC to the TGW route table
resource "aws_ec2_transit_gateway_route_table_association" "public_vpc_to_private_vpc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.public_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_rt.id
}

# Propagate the routes in the TGW route table
resource "aws_ec2_transit_gateway_route_table_propagation" "private_to_public" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.private_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_rt.id
}

# Propagate the routes in the TGW route table
resource "aws_ec2_transit_gateway_route_table_propagation" "public_to_private" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.public_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_rt.id
}
