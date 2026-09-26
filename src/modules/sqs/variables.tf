variable "queue_name" {
  type = string
}
# AI SUMMARISER PURPOSE
/*
variable "aisummarizer_arn" {
  type = string
}
*/

variable "account_id" {
  type = string
}

variable "region" {
  type = string
}

variable "soap_email_template_worker_arn" {
  type        = string
  description = "ARN of the SOAP Email Template Worker Lambda"
}

variable"soap_refine_worker_arn"{
  type        = string
  description = "ARN of the SOAP Refine Worker Lambda"

}
variable "transcription_worker_arn" {
  type        = string
  description = "ARN of the Transcription Worker Lambda" 
}

variable "soap_worker_arn"{
  type        = string
  description = "ARN of the Soap Worker Lambda" 
}