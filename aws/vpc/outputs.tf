output "vpc_id" {
  value = aws_vpc.my_vpc.id
}

output "vpc_cidr_block" {
  value = aws_vpc.my_vpc.cidr_block
}

output "ipv6_cidr_block" {
  value = aws_vpc.my_vpc.ipv6_cidr_block
}

output "vpc_arn" {
  value = aws_vpc.my_vpc.arn
}
