resource "aws_secretsmanager_secret" "products_database" {
  name = "services/products/database"
}

resource "aws_secretsmanager_secret_version" "products_database" {
  secret_id     = aws_secretsmanager_secret.products_database.id
  secret_string = jsonencode({
    username = "root"
    password = var.products_db_password
    url      = "jdbc:mysql://host.docker.internal:3306/inventory?allowPublicKeyRetrieval=true&useSSL=false&serverTimezone=UTC"
  })
}

resource "aws_secretsmanager_secret" "products_auth" {
  name = "services/products/authentication"
}

resource "aws_secretsmanager_secret_version" "products_auth" {
  secret_id     = aws_secretsmanager_secret.products_auth.id
  secret_string = jsonencode({ jwtSecret = var.shared_jwt_secret })
}

resource "aws_iam_role" "products_secret_reader" {
    name = "role-products-secret-reader"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Principal = { AWS = "arn:aws:iam::000000000000:root" }
            Action = "sts:AssumeRole"
        }]
    })
}

resource "aws_iam_policy" "products_secret_reader_policy" {
    name = "policy-products-secret-reader"
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Action = ["secretsmanager:GetSecretValue"]
            Resource = [
                "arn:aws:secretsmanager:us-east-1:000000000000:secret:${aws_secretsmanager_secret.products_database.name}-*",
                "arn:aws:secretsmanager:us-east-1:000000000000:secret:${aws_secretsmanager_secret.products_auth.name}-*"
            ]
        }]
    })
}

resource "aws_iam_role_policy_attachment" "products_secret_reader" {
    role       = aws_iam_role.products_secret_reader.name
    policy_arn = aws_iam_policy.products_secret_reader_policy.arn
}