output "repository_endpoint" {
  value = aws_ecr_repository.main.repository_url
}

output "repository_name" {
  value = aws_ecr_repository.main.name
}
