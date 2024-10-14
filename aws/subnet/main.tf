data "aws_availability_zones" "available" {
  state = "available"
}

data "terraform_remote_state" "vpc" {
  backend = "local"
  config = {
    path = "../vpc/terraform.tfstate"
  }
}

locals {
  eks_name = "eks-demo"
  vpc_name = "vpc-demo"
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = data.terraform_remote_state.vpc.outputs.vpc_id
  count                   = length(data.aws_availability_zones.available.names)
  cidr_block              = cidrsubnet(data.terraform_remote_state.vpc.outputs.vpc_cidr_block, 4, count.index)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true

  tags = {
    "Name"                   = format("%s-public-subnet-%s", local.vpc_name, element(data.aws_availability_zones.available.names, count.index))
    "tier"                   = "public"
    "karpenter.sh/discovery" = local.eks_name
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id

  tags = {
    Name = format("%s-igw", local.vpc_name)
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "${local.vpc_name}-public-rt"
  }
}

resource "aws_route_table_association" "public_route_table_assoc" {
  count          = length(aws_subnet.public_subnet[*].id)
  subnet_id      = element(aws_subnet.public_subnet[*].id, count.index)
  route_table_id = aws_route_table.public_route_table.id
}
