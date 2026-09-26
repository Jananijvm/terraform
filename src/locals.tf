locals {
  common_tags = {
    Project            = "arocord-hims"
    Application        = "HIMS"
    Environment        = var.environment
    ManagedBy          = "Terraform"
    Owner              = "MG-HEALTH-TECH"
    Repository         = "arocord-insights-terraform"
    DataClassification = "PHI"
  }
}