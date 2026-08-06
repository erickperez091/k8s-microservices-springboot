output "products_role_arn" {
    value = aws_iam_role.products_secret_reader.arn  
}

output "gateway_role_arn" {
    value = aws_iam_role.gateway_secret_reader.arn  
}

output "user_auth-role_arn" {
    value = aws_iam_role.user-auth_secret_reader.arn  
}