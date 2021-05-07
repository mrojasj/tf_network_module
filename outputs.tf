output "vpc_id" {
  value = aws_vpc.main.id
  description = "Main VPC ID"
}

output "subnet_ids" {
  value = aws_subnet.this[*].id
}