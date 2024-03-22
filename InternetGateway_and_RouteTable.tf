# Create Internet Gateway
resource "aws_internet_gateway" "ig_P18" {
  tags = {
    Name = "internet_gateway_p18"
  }
  vpc_id = aws_vpc.TF_KP18.id
}

# Create Route Table
resource "aws_route_table" "route_table_P18" {
  tags = {
    Name = "route_table_P18"
  }
  vpc_id = aws_vpc.TF_KP18.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig_P18.id
  }
}

# Create Route Table Association
resource "aws_route_table_association" "route_table_association1_P18" {
  subnet_id      = aws_subnet.public_subnet1a_P18.id
  route_table_id = aws_route_table.route_table_P18.id
}

resource "aws_route_table_association" "route_table_association2_P18" {
  subnet_id      = aws_subnet.public_subnet1b_P18.id
  route_table_id = aws_route_table.route_table_P18.id
}