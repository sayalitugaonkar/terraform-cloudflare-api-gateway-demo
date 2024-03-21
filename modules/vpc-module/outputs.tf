output "subnet-1-id" {
  value = aws_subnet.public["subnet-1"].id
}


output "vpc-id" {
  value = aws_vpc.main-vpc.id
}