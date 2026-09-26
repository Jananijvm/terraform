output "audio_bucket_name" {
  value = aws_s3_bucket.audio.bucket
}

output "document_bucket_name"{
  value=aws_s3_bucket.document.bucket
}

output "deploy_bucket_name" {
  value = aws_s3_bucket.deploy.bucket
}