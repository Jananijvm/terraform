output "layer_arns" {
  description = "Map of Lambda Layer ARNs used by lambda module"

  value = {
    core     = aws_lambda_layer_version.core.arn
    pdf      = aws_lambda_layer_version.pdf.arn
    numpy    = aws_lambda_layer_version.numpy.arn
    openai   = aws_lambda_layer_version.openai.arn
    pymysql  = aws_lambda_layer_version.pymysql.arn
    requests = aws_lambda_layer_version.requests.arn
    jose     = aws_lambda_layer_version.jose.arn
  }
}