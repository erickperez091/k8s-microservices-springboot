variable "products_db_password" {
    type        = string
    sensitive   = true
}

variable "user_auth_db_password" {
    type        = string
    sensitive   = true
}

variable "shared_jwt_secret" {
    type        = string
    sensitive   = true
}