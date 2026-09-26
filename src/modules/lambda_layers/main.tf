
locals {
  core_key     = "${var.artifact_base_path}/${var.layer_core_key}"
  pdf_key      = "${var.artifact_base_path}/${var.layer_pdf_key}"
  numpy_key    = "${var.artifact_base_path}/${var.layer_numpy_key}"
  openai_key   = "${var.artifact_base_path}/${var.layer_openai_key}"
  pymysql_key  = "${var.artifact_base_path}/${var.layer_pymysql_key}"
  requests_key = "${var.artifact_base_path}/${var.layer_requests_key}"
  jose_key     ="${var.artifact_base_path}/${var.layer_jose_key}"
}


resource "aws_lambda_layer_version" "core" {
  layer_name               = "layer-core-arocord-insight-aisummarizer"
  s3_bucket = var.artifact_bucket
  s3_key                   = local.core_key
  compatible_runtimes      = ["python3.13"]
  compatible_architectures = ["x86_64", "arm64"]
  description              = "Core Python dependencies for Arocord Insight Summariser"
}

resource "aws_lambda_layer_version" "pdf" {
  layer_name               = "layer-pdf-arocord-insight-aisummarizer"
  s3_bucket = var.artifact_bucket
  s3_key                   = local.pdf_key
  compatible_runtimes      = ["python3.13"]
  compatible_architectures = ["x86_64", "arm64"]
  description              = "PDF processing libraries"
}


resource "aws_lambda_layer_version" "numpy" {
  layer_name               = "numpy_scipy"
  s3_bucket = var.artifact_bucket
  s3_key                   = local.numpy_key
  compatible_runtimes      = ["python3.13"]
  compatible_architectures = ["x86_64", "arm64"]
  description              = "NumPy + SciPy optimized binaries"
}


resource "aws_lambda_layer_version" "openai" {
  layer_name               = "openai-layer"
  s3_bucket = var.artifact_bucket
  s3_key                   = local.openai_key
  compatible_runtimes      = ["python3.13"]
  compatible_architectures = ["x86_64", "arm64"]
  description              = "OpenAI SDK dependencies layer"
}


resource "aws_lambda_layer_version" "pymysql" {
  layer_name               = "pymysql"
  s3_bucket = var.artifact_bucket
  s3_key                   = local.pymysql_key
  compatible_runtimes      = ["python3.13"]
  compatible_architectures = ["x86_64", "arm64"]
  description              = "PyMySQL dependencies"
}

resource "aws_lambda_layer_version" "requests" {
  layer_name               = "requests-toolbelt"
  s3_bucket = var.artifact_bucket
  s3_key                   = local.requests_key
  compatible_runtimes      = ["python3.13"]
  compatible_architectures = ["x86_64", "arm64"]
  description              = "Requests Toolbelt utilities"
}

resource "aws_lambda_layer_version" "jose" {
  layer_name               = "python-jose"
  s3_bucket = var.artifact_bucket
  s3_key                   = local.jose_key
  compatible_runtimes      = ["python3.13"]
  compatible_architectures = ["x86_64", "arm64"]
  description              = "python jose utilities"
}