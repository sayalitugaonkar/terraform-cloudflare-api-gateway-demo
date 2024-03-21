resource "aws_vpc" "main-vpc" {

  cidr_block = var.vpc-cidr

  tags = {
    Name = var.vpc_name
  }
}


resource "aws_subnet" "public" {
  depends_on = [
    aws_vpc.main-vpc
  ]

  for_each   = var.env_module.subnet_pub
  cidr_block = each.value.cidr_block

  vpc_id            = aws_vpc.main-vpc.id
  availability_zone = each.value.availability_zone

  tags = {

    Name = join("-", ["${terraform.workspace}", each.value.tag_name])


  }
}


resource "aws_subnet" "private" {
  depends_on = [
    aws_vpc.main-vpc
  ]
  for_each = var.env_module.subnets

  cidr_block              = each.value.cidr_block
  vpc_id                  = aws_vpc.main-vpc.id
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = false
  tags = {


    Name = join("-", ["${terraform.workspace}", each.value.tag_name])
  }
}

resource "aws_internet_gateway" "igw" {

  vpc_id = aws_vpc.main-vpc.id
  tags = {
    Name = join("-", ["${terraform.workspace}", "aws_internet_gateway-igw"])
  }
}

resource "aws_route_table" "public-crt" {


  vpc_id = aws_vpc.main-vpc.id

  route {
    //associated subnet can reach everywhere
    cidr_block = "0.0.0.0/0" //CRT uses this IGW to reach internet
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name        = "${terraform.workspace}-public-rt"
    Environment = "${terraform.workspace}"
  }
}

#Associate CRT and Subnet
resource "aws_route_table_association" "crta-public-subnet-1" {

  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public-crt.id
}


resource "aws_eip" "nat-gateway-eip" {



  depends_on = [
    aws_route_table_association.crta-public-subnet-1
  ]
  domain = "vpc"
}

resource "aws_nat_gateway" "ngw" {
  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.

  depends_on = [
    aws_eip.nat-gateway-eip,
    aws_internet_gateway.igw
  ]
  allocation_id = aws_eip.nat-gateway-eip.id

  subnet_id = aws_subnet.public[element(keys(aws_subnet.public), 0)].id


  tags = {
    Name = "${terraform.workspace}-gw-NAT"
  }

}


# Creating a Route Table for the Nat Gateway!
resource "aws_route_table" "NAT-Gateway-RT" {

  depends_on = [
    aws_nat_gateway.ngw
  ]

  vpc_id = aws_vpc.main-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }

  tags = {
    Name = "${terraform.workspace}-RT-NAT"
  }

}

# Associating the Route table for NAT Gateway to private Subnet!
# Creating an Route Table Association of the NAT Gateway route 
# table with the Private Subnet!
resource "aws_route_table_association" "Nat-Gateway-RT-Association" {

  depends_on = [
    aws_route_table.NAT-Gateway-RT
  ]

  #  Private Subnet ID for adding this route table to the DHCP server of Private subnet!

  for_each  = aws_subnet.private
  subnet_id = each.value.id
  # Route Table ID
  route_table_id = aws_route_table.NAT-Gateway-RT.id
}