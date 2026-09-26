variable "lambda_invoke_arns" {
  type = map(string)
}

variable "lambda_function_names" {
  type = map(string)
}

variable "lambda_arns" {
  type = map(string)
}

variable "user_pool_id" {
  type = string
}

variable "environment" {
  type = string
}
