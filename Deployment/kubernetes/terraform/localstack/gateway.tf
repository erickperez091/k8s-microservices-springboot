resource "aws_secretsmanager_secret" "gateway_auth" {
  name = "services/gateway/authentication"
}

resource "aws_secretsmanager_secret_version" "gateway_auth" {
  secret_id     = aws_secretsmanager_secret.gateway_auth.id
  secret_string = jsonencode({ jwtSecret = var.shared_jwt_secret })
}

resource "aws_iam_role" "gateway_secret_reader" {
    name = "role-gateway-secret-reader"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Principal = { AWS = "arn:aws:iam::000000000000:root" }
            Action = "sts:AssumeRole"
        }]
    })
}

resource "aws_iam_policy" "gateway_secret_reader_policy" {
    name = "policy-gateway-secret-reader"
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Action = ["secretsmanager:GetSecretValue"]
            Resource = [
                "arn:aws:secretsmanager:us-east-1:000000000000:secret:${aws_secretsmanager_secret.gateway_auth.name}-*"
            ]
        }]
    })
}

resource "aws_iam_role_policy_attachment" "gateway_secret_reader" {
    role       = aws_iam_role.gateway_secret_reader.name
    policy_arn = aws_iam_policy.gateway_secret_reader_policy.arn
}