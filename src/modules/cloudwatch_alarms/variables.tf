variable "environment" {
  type = string
}

variable "function_names" {
  type = list(string)
}

variable "sns_topic_arn" {
  type = string
}