output "vpc_id" {
  value = aws_vpc.this.id
}
output "private_subnet_ids" {
  description = "Private subnet IDs for RDS"
  value       = aws_subnet.private[*].id
}




output "embeddings_sg_id" {
  description = "Security group for Aurora embeddings"
  value       = aws_security_group.embeddings.id
}

output "lambda_sg_id" {
  description = "Security group for Lambda functions"
  value       = aws_security_group.lambda.id
}

output "rds_sg_id" {
  description = "Security group for RDS"
  value       = aws_security_group.rds.id
}