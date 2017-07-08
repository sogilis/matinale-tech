resource "aws_vpc" "mat_tech" {
  cidr_block = "10.0.0.0/16"
  tags {
    Name = "mat_tech_vpc"
  }
}
