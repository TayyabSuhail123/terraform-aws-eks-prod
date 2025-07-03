resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge(
    var.tags,
    {
      Name = "eks-vpc"
    }
  )
}


resource "aws_subnet" "public" {
  for_each = {
    for idx, cidr in var.public_subnet_cidrs :
    idx => {
      cidr = cidr
      az   = var.azs[idx]
    }
  }

  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name = "public-subnet-${each.key}"
    }
  )
}

resource "aws_subnet" "private" {
  for_each = {
    for idx, cidr in var.private_subnet_cidrs :
    idx => {
      cidr = cidr
      az   = var.azs[idx]
    }
  }

  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az

  tags = merge(
    var.tags,
    {
      Name = "private-subnet-${each.key}"
    }
  )
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = merge(
    var.tags,
    {
      Name = "eks-igw"
    }
  )
}


resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(
    var.tags,
    {
      Name = "public-route-table"
    }
  )
}

resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? 1 : 0

  vpc = true

  tags = merge(
    var.tags,
    {
      Name = "nat-eip"
    }
  )
}


resource "aws_route_table" "private" {
  count = var.enable_nat_gateway ? 1 : 0

  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[0].id
  }

  tags = merge(
    var.tags,
    {
      Name = "private-route-table"
    }
  )
}

resource "aws_route_table_association" "private" {
  for_each = var.enable_nat_gateway ? aws_subnet.private : {}

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[0].id
}