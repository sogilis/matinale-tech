# private network base conf for aws

resource "aws_vpc" "mat_tech" {
  cidr_block = "10.0.0.0/16"
  tags {
    Name = "mat_tech_vpc"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = "${aws_vpc.mat_tech.id}"
}

resource "aws_route_table" "public_route_table" {
  vpc_id = "${aws_vpc.mat_tech.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.internet_gateway.id}"
  }
  tags {
    Name = "public subnet"
  }
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id = "${aws_vpc.mat_tech.id}"
  cidr_block = "10.0.0.0/24"
  availability_zone = "eu-west-1a"
  tags {
    Name = "public subnet"
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id = "${aws_vpc.mat_tech.id}"
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-west-1b"
  tags {
    Name = "public subnet"
  }
}

resource "aws_subnet" "public_subnet_c" {
  vpc_id = "${aws_vpc.mat_tech.id}"
  cidr_block = "10.0.2.0/24"
  availability_zone = "eu-west-1c"
  tags {
    Name = "public subnet"
  }
}

resource "aws_route_table_association" "eu-west-1a-public" {
    subnet_id = "${aws_subnet.public_subnet_a.id}"
    route_table_id = "${aws_route_table.public_route_table.id}"
}

resource "aws_route_table_association" "eu-west-1b-public" {
    subnet_id = "${aws_subnet.public_subnet_b.id}"
    route_table_id = "${aws_route_table.public_route_table.id}"
}

resource "aws_route_table_association" "eu-west-1c-public" {
    subnet_id = "${aws_subnet.public_subnet_c.id}"
    route_table_id = "${aws_route_table.public_route_table.id}"
}
