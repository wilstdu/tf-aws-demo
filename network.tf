resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "${data.aws_region.current.name}-Dev"
  }
}

resource "aws_subnet" "pub_subnet_1a" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = "eu-central-1a"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "${data.aws_region.current.name}-Dev-Public-1a"
  }
}

resource "aws_subnet" "priv_subnet_1a" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = "eu-central-1a"
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "${data.aws_region.current.name}-Dev-Private-1a"
  }
}

resource "aws_security_group" "lambda_sg" {
  name        = "${var.project_name}-lambda-${var.order_processor_lambda_name}-Dev-SG"
  description = "Rules for inbound/outbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    protocol    = -1
    self        = true
    from_port   = 0
    to_port     = 0
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.eu-central-1.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_vpc.vpc.default_route_table_id]
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_eip" "eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.internet_gateway]
}

resource "aws_nat_gateway" "nat_1a" {
  allocation_id = "${aws_eip.eip.id}"
  subnet_id     = "${aws_subnet.pub_subnet_1a.id}"
  depends_on    = [aws_internet_gateway.internet_gateway]
}
resource "aws_route_table" "route_table_private" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_1a.id
  }

  tags = {
    Name = "${data.aws_region.current.name}-Dev-Private-ROUTE"
  }
}

resource "aws_route_table" "route_table_public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "${data.aws_region.current.name}-Dev-Public-ROUTE"
  }
}

resource "aws_route_table_association" "route_table_association_public_1a" {
  subnet_id      = aws_subnet.pub_subnet_1a.id
  route_table_id = aws_route_table.route_table_public.id
}

resource "aws_route_table_association" "route_table_association_private_1a" {
  subnet_id      = aws_subnet.priv_subnet_1a.id
  route_table_id = aws_route_table.route_table_private.id
}
