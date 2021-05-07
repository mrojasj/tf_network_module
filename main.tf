resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
  tags = {
	  Name = "vpc-tf"
  }
}

data "aws_availability_zones" "this"{
  state = "available"
}

resource "aws_subnet" "this" {
  count = length(var.snet_cidr_block_list)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.snet_cidr_block_list[count.index]
  availability_zone = data.aws_availability_zones.this.names[count.index % 2 == 0 ? 0 : 1]
  tags = {
	  Name = "snet-tf-0${count.index}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw-tf"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  
  tags = {
    Name = "rt-tf-public"
  }
}

resource "aws_route_table_association" "this" {
  count = floor(length(var.snet_cidr_block_list) / 2)
  subnet_id      = aws_subnet.this[count.index].id
  route_table_id = aws_route_table.public.id
}