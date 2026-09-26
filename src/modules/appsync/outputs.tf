output "appsync_api_id" {
  value = aws_appsync_graphql_api.this.id
}

output "appsync_api_url" {
  value = aws_appsync_graphql_api.this.uris["GRAPHQL"]
}


output "transcript_appsync_api_id" {
  value = aws_appsync_graphql_api.transcript_api.id
}

output "transcript_appsync_api_url" {
  value = aws_appsync_graphql_api.transcript_api.uris["GRAPHQL"]
}

