#Locals

locals{
  snet_count = pow(2, var.snet_extra_bits)
  rt_assoc_count = floor(local.snet_count / 2)
}
  
#Data sources

data "aws_availability_zones" "this"{
  state = "available"
}

# Resources

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
  tags = {
	  Name = "vpc-tf"
  }
}

resource "aws_subnet" "this" {
  count = local.snet_count
  vpc_id     = aws_vpc.main.id
  cidr_block = cidrsubnet(var.vpc_cidr_block, var.snet_extra_bits, count.index)
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
  count = local.rt_assoc_count
  subnet_id      = aws_subnet.this[count.index].id
  route_table_id = aws_route_table.public.id
}