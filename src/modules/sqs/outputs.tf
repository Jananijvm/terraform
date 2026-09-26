# AI SUMMARISER PURPOSE

/*
output "summariser_queue_url" {
  value = aws_sqs_queue.summarizer_queue.id
}

output "queue_arn" {
  value = aws_sqs_queue.summarizer_queue.arn
}
*/

output  "email_queue_url" {
  value =aws_sqs_queue.email_queue.id
}

output "refine_queue_url"{
  value = aws_sqs_queue.refine_queue.id
}


output "soap_queue_url"{
  value = aws_sqs_queue.soap_queue.id
}

output "transcribe_queue_url"{
  value =aws_sqs_queue.transcribe_queue.id
}