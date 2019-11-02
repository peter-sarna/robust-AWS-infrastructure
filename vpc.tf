# VPC

resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = "true"
  tags = {
    Name = "main_vpc"
  }
}

# IGW

resource "aws_internet_gateway" "IGW" {
  vpc_id = "${aws_vpc.main_vpc.id}"
  tags = {
    Name = "main_IGW"
  }
}

# public subnets

resource "aws_subnet" "public_subnet_1" {
  cidr_block = "10.0.1.0/24"
  vpc_id = "${aws_vpc.main_vpc.id}"
  map_public_ip_on_launch = "true"
  availability_zone = "eu-central-1a"
  tags = {
    Name = "public_subnet_1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  cidr_block = "10.0.3.0/24"
  vpc_id = "${aws_vpc.main_vpc.id}"
  map_public_ip_on_launch = "true"
  availability_zone = "eu-central-1b"
  tags = {
    Name = "public_subnet_2"
  }
}

resource "aws_subnet" "public_subnet_3" {
  cidr_block = "10.0.5.0/24"
  vpc_id = "${aws_vpc.main_vpc.id}"
  map_public_ip_on_launch = "true"
  availability_zone = "eu-central-1c"
  tags = {
    Name = "public_subnet_3"
  }
}

# private subnets

resource "aws_subnet" "private_subnet_1" {
  cidr_block = "10.0.2.0/24"
  vpc_id = "${aws_vpc.main_vpc.id}"
  map_public_ip_on_launch = "false"
  availability_zone = "eu-central-1a"
  tags = {
    Name = "private_subnet_1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  cidr_block = "10.0.4.0/24"
  vpc_id = "${aws_vpc.main_vpc.id}"
  map_public_ip_on_launch = "false"
  availability_zone = "eu-central-1b"
  tags = {
    Name = "private_subnet_2"
  }
}

resource "aws_subnet" "private_subnet_3" {
  cidr_block = "10.0.6.0/24"
  vpc_id = "${aws_vpc.main_vpc.id}"
  map_public_ip_on_launch = "false"
  availability_zone = "eu-central-1c"
  tags = {
    Name = "private_subnet_3"
  }
}

# RT

resource "aws_route_table" "public_RT" {
  vpc_id = "${aws_vpc.main_vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.IGW.id}"
  }

  tags = {
    Name = "public_RT"
  }
}

resource "aws_route_table" "private_RT_1" {
  vpc_id = "${aws_vpc.main_vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat-gw_1.id}"
  }
  tags = {
    Name = "private_RT_1"
  }
}

resource "aws_route_table" "private_RT_2" {
  vpc_id = "${aws_vpc.main_vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat-gw_2.id}"
  }
  tags = {
    Name = "private_RT_2"
  }
}

resource "aws_route_table" "private_RT_3" {
  vpc_id = "${aws_vpc.main_vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat-gw_3.id}"
  }
  tags = {
    Name = "private_RT_3"
  }
}
# EIP

resource "aws_eip" "nat_eip_1" {
  vpc = "true"
}

resource "aws_eip" "nat_eip_2" {
  vpc = "true"
}

resource "aws_eip" "nat_eip_3" {
  vpc = "true"
}

# NAT GW

resource "aws_nat_gateway" "nat-gw_1" {
  allocation_id = "${aws_eip.nat_eip_1.id}"
  subnet_id = "${aws_subnet.public_subnet_1.id}"
  depends_on = ["aws_internet_gateway.IGW"]
}

resource "aws_nat_gateway" "nat-gw_2" {
  allocation_id = "${aws_eip.nat_eip_2.id}"
  subnet_id = "${aws_subnet.public_subnet_2.id}"
  depends_on = ["aws_internet_gateway.IGW"]
}

resource "aws_nat_gateway" "nat-gw_3" {
  allocation_id = "${aws_eip.nat_eip_3.id}"
  subnet_id = "${aws_subnet.public_subnet_3.id}"
  depends_on = ["aws_internet_gateway.IGW"]
}

# RT association

resource "aws_route_table_association" "public_sub_rt_1" {
  subnet_id = "${aws_subnet.public_subnet_1.id}"
  route_table_id = "${aws_route_table.public_RT.id}"
}
resource "aws_route_table_association" "public_sub_rt_2" {
  subnet_id = "${aws_subnet.public_subnet_2.id}"
  route_table_id = "${aws_route_table.public_RT.id}"
}
resource "aws_route_table_association" "public_sub_rt_3" {
  subnet_id = "${aws_subnet.public_subnet_3.id}"
  route_table_id = "${aws_route_table.public_RT.id}"
}

resource "aws_route_table_association" "private_sub_rt_1" {
  subnet_id = "${aws_subnet.private_subnet_1.id}"
  route_table_id = "${aws_route_table.private_RT_1.id}"
}
resource "aws_route_table_association" "private_sub_rt_2" {
  subnet_id = "${aws_subnet.private_subnet_2.id}"
  route_table_id = "${aws_route_table.private_RT_2.id}"
}
resource "aws_route_table_association" "private_sub_rt_3" {
  subnet_id = "${aws_subnet.private_subnet_3.id}"
  route_table_id = "${aws_route_table.private_RT_3.id}"
}
