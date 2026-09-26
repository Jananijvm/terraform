data "aws_region" "current" {}

resource "aws_ecr_repository" "repo" {
  for_each = toset([
    "arocord-insights-standalone-soap-email-template-worker-lambda",
    "arocord-insights-standalone-transcription-worker-lambda",
    "arocord-insights-standalone-soap-refine-worker-lambda",
    "arocord-insights-standalone-soap-worker-lambda"
  ])

  name = "${each.value}-${data.aws_region.current.id}"
  force_delete = true  
}