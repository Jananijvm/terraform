variable "artifact_bucket" {
  description = "S3 bucket storing layer artifacts"
  type        = string
}

variable "artifact_base_path" {
  description = "Base path like ARTIFACT_KEY"
  type        = string
}

variable "layer_core_key"     { type = string }
variable "layer_pdf_key"      { type = string }
variable "layer_numpy_key"    { type = string }
variable "layer_openai_key"   { type = string }
variable "layer_pymysql_key"  { type = string }
variable "layer_requests_key" { type = string }
variable "layer_jose_key"     { type = string }