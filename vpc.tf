#
# VPC Resources
#  * VPC
#  * Subnets
#  * Internet Gateway
#  * Route Tables
#  * NAT Gateway
#  * Elastic IP

resource "aws_vpc" "vb" {
  cidr_block = "10.0.0.0/16"

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = map(
    "Name", "${var.cluster-name}/VPC",
    "kubernetes.io/cluster/${var.cluster-name}", "shared",
  )
}

# Private subnets
resource "aws_subnet" "vb-private" {
  count = 3

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = aws_vpc.vb.id

  tags = map(
    "Name", "${var.cluster-name}/SubnetPrivate-${data.aws_availability_zones.available.names[count.index]}",
    "kubernetes.io/cluster/${var.cluster-name}", "shared",
    "kubernetes.io/role/internal-elb", 1
  )
}

# Public subnets
resource "aws_subnet" "vb-public" {
  count = 3

  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.0.10${count.index}.0/24"
  vpc_id                  = aws_vpc.vb.id
  map_public_ip_on_launch = true

  tags = map(
    "Name", "${var.cluster-name}/SubnetPublic-${data.aws_availability_zones.available.names[count.index]}",
    "kubernetes.io/cluster/${var.cluster-name}", "shared",
    "kubernetes.io/role/elb", 1
  )
}

resource "aws_internet_gateway" "vb" {
  vpc_id = aws_vpc.vb.id
  tags = {
    Name = "${var.cluster-name}/InternetGateway"
  }
}

resource "aws_route_table" "vb-public" {
  vpc_id = aws_vpc.vb.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vb.id
  }

  tags = {
    Name = "${var.cluster-name}/PublicRouteTable"
  }
}

resource "aws_route_table_association" "vb-public" {
  count = 3

  subnet_id      = aws_subnet.vb-public.*.id[count.index]
  route_table_id = aws_route_table.vb-public.id
}

# NAT Gateway to allow traffic from private subnets to Internet via NAT gateway
resource "aws_eip" "nat" {
  depends_on = [aws_internet_gateway.vb]
  vpc        = true
}

resource "aws_nat_gateway" "vb" {
  depends_on    = [aws_internet_gateway.vb]
  subnet_id     = aws_subnet.vb-public[0].id
  allocation_id = aws_eip.nat.id
}

# Routing table for private subnets
resource "aws_route_table" "vb-private" {
  vpc_id = aws_vpc.vb.id
  tags = {
    Name = "${var.cluster-name}/PrivateRouteTable"
  }
}

resource "aws_route_table_association" "vb-private" {
  count = 3

  subnet_id      = aws_subnet.vb-private.*.id[count.index]
  route_table_id = aws_route_table.vb-private.id
}

resource "aws_route" "private_route" {
  route_table_id         = aws_route_table.vb-private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.vb.id
}
