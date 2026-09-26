variable "environment" {}
variable "purpose" {}

variable "versioned" {
  type = bool
}

variable "removal_policy" {
  type = string
}

variable "cors_rules" {
  type = any
}
variable "audio_bucket_base" {
  type = string
}

variable "document_bucket_base" {
  type = string
}

variable "deploy_bucket_base" {
  type = string
}

