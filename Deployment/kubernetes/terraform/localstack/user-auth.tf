resource "aws_secretsmanager_secret" "user-auth_database" {
  name = "services/user-auth/database"
}

resource "aws_secretsmanager_secret_version" "user-auth_database" {
  secret_id     = aws_secretsmanager_secret.user-auth_database.id
  secret_string = jsonencode({
    username = "root"
    password = var.user_auth_db_password
    url      = "jdbc:mysql://host.docker.internal:3306/user_data?allowPublicKeyRetrieval=true&useSSL=false&serverTimezone=UTC"
  })
}

resource "aws_secretsmanager_secret" "user-auth_auth" {
  name = "services/user-auth/authentication"
}

resource "aws_secretsmanager_secret_version" "user-auth_auth" {
  secret_id     = aws_secretsmanager_secret.user-auth_auth.id
  secret_string = jsonencode({ jwtSecret = var.shared_jwt_secret })
}

resource "aws_iam_role" "user-auth_secret_reader" {
    name = "role-user-auth-secret-reader"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Principal = { AWS = "arn:aws:iam::000000000000:root" }
            Action = "sts:AssumeRole"
        }]
    })
}

resource "aws_iam_policy" "user-auth_secret_reader_policy" {
    name = "policy-user-auth-secret-read"
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Action = ["secretsmanager:GetSecretValue"]
            Resource = [
                "arn:aws:secretsmanager:us-east-1:000000000000:secret:${aws_secretsmanager_secret.user-auth_database.name}-*",
                "arn:aws:secretsmanager:us-east-1:000000000000:secret:${aws_secretsmanager_secret.user-auth_auth.name}-*"
            ]
        }]
    })
}

resource "aws_iam_role_policy_attachment" "user-auth_secret_reader" {
    role       = aws_iam_role.user-auth_secret_reader.name
    policy_arn = aws_iam_policy.user-auth_secret_reader_policy.arn
}