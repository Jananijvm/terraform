data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  user_pool_name  = "${var.user_pool_name}-${data.aws_region.current.region}"
  app_client_name = "${var.app_client_name}-${data.aws_region.current.region}"
  domain_prefix   = "${data.aws_region.current.region}-${var.domain_prefix}-${random_string.domain_suffix.result}"
  name_prefix = "${var.environment}-${var.purpose}-${data.aws_region.current.region}"
  identity_pool_name = "${var.environment}-${var.purpose}-identity-pool-${data.aws_region.current.region}"
  auth_role_name = "${var.environment}-${var.purpose}-cognito-auth-role-${data.aws_region.current.region}"
  managed_policy_name = "${var.environment}-${var.purpose}-cognito-policy-${data.aws_region.current.region}"
  inline_policy_name = "${var.environment}-${var.purpose}-s3-access-policy-${data.aws_region.current.region}"
}

terraform {
  required_providers {
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

resource "random_string" "domain_suffix" {
  length  = 8
  special = false
  upper   = false
}


# User Pool

resource "aws_cognito_user_pool" "this" {
  name = local.user_pool_name
 
  auto_verified_attributes = ["email"]
  username_attributes      = ["email"]
  
  deletion_protection = "ACTIVE"  


  lifecycle {
    prevent_destroy = true
  }

  schema {
	name                = "primary_adminid"
	attribute_data_type = "String"
	developer_only_attribute = false
	mutable            = true
	required           = false

	string_attribute_constraints {
		min_length = 0
		max_length = 2048
	}
 }

 schema {
	name                = "tenant_id"
	attribute_data_type = "String"
	developer_only_attribute = false
	mutable            = true
	required           = false

	string_attribute_constraints {
		min_length = 0
		max_length = 2048
	}
 }

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_uppercase = true
    require_numbers   = true
    require_symbols   = true
    temporary_password_validity_days = 7
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  verification_message_template {
    default_email_option  = "CONFIRM_WITH_LINK"
    email_subject_by_link = var.email_subject
    email_message_by_link = var.email_html
  }

  # INVITATION MESSAGE (TEMP PASSWORD EMAIL)
admin_create_user_config {

  allow_admin_create_user_only = true

  invite_message_template {
    email_subject = "Arocord Temporary Credentials"

    email_message = <<EOF
<!DOCTYPE html>
<html>
  <body style="font-family: Arial, sans-serif; background-color: #f4f4f4; padding: 20px;">
    <div style="max-width: 600px; background: #fff; padding: 20px; border-radius: 6px; margin: auto;">
      <h2 style="color: #1A57EB;">Welcome to AroCord!</h2>
      <p>Hello {username}!</p>
      <p>For login please use the temporary password below:</p>

      <p style="word-break: break-all;">
        {####}
      </p>

      <p>If you didn’t register for AroCord, you can safely ignore this message.</p>
      <p>Thanks,<br>MG Cares...</p>
    </div>
  </body>
</html>
EOF

    sms_message = "Your username is {username} and temporary password is {####}."
  }
}
}



# App Client

resource "aws_cognito_user_pool_client" "this" {
  name         = local.app_client_name
  user_pool_id = aws_cognito_user_pool.this.id

  generate_secret = false

  allowed_oauth_flows_user_pool_client = true

  allowed_oauth_flows = [
    "code",
    "implicit"
  ]

  allowed_oauth_scopes = [
    "openid",
    "email",
    "phone",
    "aws.cognito.signin.user.admin"
  ]

  supported_identity_providers = ["COGNITO"]
  callback_urls = var.callback_urls
  logout_urls   = var.logout_urls

access_token_validity = var.access_token_days * 24 * 60 
id_token_validity = var.id_token_days * 24 * 60
 refresh_token_validity = var.refresh_token_days

token_validity_units {
  access_token  = "minutes"
  id_token      = "minutes"
  refresh_token = "days"
}

  prevent_user_existence_errors = "ENABLED"
  enable_token_revocation       = true

  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]
}



# Hosted UI Domain

resource "aws_cognito_user_pool_domain" "this" {
  domain       = local.domain_prefix
  user_pool_id = aws_cognito_user_pool.this.id
}
resource "time_sleep" "wait_for_domain" {
  depends_on = [aws_cognito_user_pool_domain.this]

  create_duration = "60s"
}


# User Groups (RBAC)

resource "aws_cognito_user_group" "groups" {
  for_each = toset(var.user_groups)

  name         = each.value
  user_pool_id = aws_cognito_user_pool.this.id
}



resource "aws_cognito_managed_login_branding" "client" {
  client_id    = aws_cognito_user_pool_client.this.id
  user_pool_id = aws_cognito_user_pool.this.id
 
  use_cognito_provided_values = true

  lifecycle {
    ignore_changes = all
  }
}


# Identity Pool

resource "aws_cognito_identity_pool" "this" {
  identity_pool_name               = local.identity_pool_name
  allow_unauthenticated_identities = false
  allow_classic_flow               = true

  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.this.id
    provider_name           = aws_cognito_user_pool.this.endpoint
    server_side_token_check = false
  }
}


# IAM Role for Authenticated Users

resource "aws_iam_role" "authenticated" {
  name = local.auth_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "cognito-identity.amazonaws.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "cognito-identity.amazonaws.com:aud" = aws_cognito_identity_pool.this.id
          }
          "ForAnyValue:StringLike" = {
            "cognito-identity.amazonaws.com:amr" = "authenticated"
          }
        }
      }
    ]
  })
}


# Managed Policy for Cognito and Identity

resource "aws_iam_policy" "cognito_managed" {
  name = local.managed_policy_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cognito-identity:GetCredentialsForIdentity"
        ]
        Resource = ["*"]
      },
      {
        Effect = "Allow"
        Action = [
          "cognito-idp:AdminCreateUser",
          "cognito-idp:AdminAddUserToGroup",
          "cognito-idp:AdminGetUser",
          "cognito-idp:AdminDeleteUser",
          "cognito-idp:AdminListGroupsForUser",
		  "cognito-idp:ListUsers"
        ]
        Resource = [
          aws_cognito_user_pool.this.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cognito_managed" {
  role       = aws_iam_role.authenticated.name
  policy_arn = aws_iam_policy.cognito_managed.arn
}


# Inline Policy for S3 Access

resource "aws_iam_role_policy" "s3_access" {
  name = local.inline_policy_name
  role = aws_iam_role.authenticated.id

  policy = jsonencode({
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "AllowReadWritePatientDocuments",
			"Effect": "Allow",
			"Action": [
				"s3:GetObject",
				"s3:PutObject",
				"s3:DeleteObject"
			],
			"Resource": "arn:aws:s3:::${var.document_bucket_name}/patientReports/*"
		},
		{
			"Sid": "AllowReadWriteTempPatientDocuments",
			"Effect": "Allow",
			"Action": [
				"s3:GetObject",
				"s3:PutObject",
				"s3:DeleteObject"
			],
			"Resource": "arn:aws:s3:::${var.document_bucket_name}/temp/patientReports/*"
		},
		{
			"Sid": "AllowReadWritecomprehensiveJobs",
			"Effect": "Allow",
			"Action": [
				"s3:GetObject",
				"s3:PutObject",
				"s3:DeleteObject"
			],
			"Resource": "arn:aws:s3:::${var.document_bucket_name}/comprehensiveJobs/*"
		},
		{
			"Sid": "AllowListBucketForPatientReports",
			"Effect": "Allow",
			"Action": "s3:ListBucket",
			"Resource": "arn:aws:s3:::${var.document_bucket_name}",
			"Condition": {
				"StringLike": {
					"s3:prefix": [
						"patientReports/*",
						"temp/patientReports/*"
					]
				}
			}
		},
		{
			"Sid": "AllowReadWriteSummarizedDocuments",
			"Effect": "Allow",
			"Action": [
				"s3:GetObject",
				"s3:PutObject",
				"s3:DeleteObject"
			],
			"Resource": "arn:aws:s3:::${var.document_bucket_name}/summaryReports/*"
		},
		{
			"Sid": "AllowReadWriteFacilityInformation",
			"Effect": "Allow",
			"Action": [
				"s3:GetObject",
				"s3:PutObject",
				"s3:DeleteObject"
			],
			"Resource": "arn:aws:s3:::${var.document_bucket_name}/facilityInformation/*"
		},
		{
			"Sid": "AllowProfileImages",
			"Effect": "Allow",
			"Action": [
				"s3:GetObject",
				"s3:PutObject",
				"s3:DeleteObject"
			],
			"Resource": "arn:aws:s3:::${var.document_bucket_name}/profileImage/*"
		},
    
		{
			"Sid": "AllowAudioUploadOnly",
			"Effect": "Allow",
			"Action": [
				"s3:PutObject",
				"s3:AbortMultipartUpload",
				"s3:ListMultipartUploadParts",
				"s3:CompleteMultipartUpload"
			],
			"Resource": "arn:aws:s3:::${var.audio_bucket_name}/uploads-audio/*"
		},
		{
			"Sid": "AllowReadWriteTranscript",
			"Effect": "Allow",
			"Action": [
				"s3:GetObject",
				"s3:PutObject",
				"s3:DeleteObject"
			],
			"Resource": "arn:aws:s3:::${var.audio_bucket_name}/transcription-output/*"
		},
		{
			"Sid": "AllowReadWriteSoap",
			"Effect": "Allow",
			"Action": [
				"s3:GetObject",
				"s3:PutObject"
			],
			"Resource": "arn:aws:s3:::${var.audio_bucket_name}/soap-notes/*"
		},
		{
			"Sid": "AllowReadWriteRefineNotes",
			"Effect": "Allow",
			"Action": [
				"s3:GetObject",
				"s3:PutObject"
			],
			"Resource": "arn:aws:s3:::${var.audio_bucket_name}/refine-notes/*"
		},
		{
			"Sid": "AllowReadWriteEmailNotes",
			"Effect": "Allow",
			"Action": [
				"s3:GetObject",
				"s3:PutObject"
			],
			"Resource": "arn:aws:s3:::${var.audio_bucket_name}/emails/*"
		},
		{
			"Sid": "AllowQuickVisitSoap",
			"Effect": "Allow",
			"Action": [
				"s3:GetObject",
				"s3:PutObject"
			],
			"Resource": "arn:aws:s3:::${var.audio_bucket_name}/quick-visit-soap/*"
		},
		{
			"Sid": "AllowQuickVisitRefine",
			"Effect": "Allow",
			"Action": [
				"s3:GetObject",
				"s3:PutObject"
			],
			"Resource": "arn:aws:s3:::${var.audio_bucket_name}/quick-visit-refine/*"
		},
		{
			"Sid": "AllowQuickVisitOutput",
			"Effect": "Allow",
			"Action": [
				"s3:GetObject",
				"s3:PutObject"
			],
			"Resource": "arn:aws:s3:::${var.audio_bucket_name}/quick-visit-output/*"
		},
		{
			"Sid": "AllowQuickVisitEmail",
			"Effect": "Allow",
			"Action": [
				"s3:GetObject",
				"s3:PutObject"
			],
			"Resource": "arn:aws:s3:::${var.audio_bucket_name}/quick-visit-emails/*"
		},
		{
			"Sid": "AllowReadWriteMedications",
			"Effect": "Allow",
			"Action": [
				"s3:GetObject",
				"s3:PutObject",
				"s3:DeleteObject"
			],
			"Resource": "arn:aws:s3:::${var.audio_bucket_name}/medications/*"
		},
		{
			"Sid": "AllowListBucketForJsonPrefixes",
			"Effect": "Allow",
			"Action": "s3:ListBucket",
			"Resource": "arn:aws:s3:::${var.audio_bucket_name}",
			"Condition": {
				"StringLike": {
					"s3:prefix": [
						"transcription-output/*",
						"refine-notes/*",
						"soap-notes/*",
						"emails/*",
						"quick-visit-soap/*",
						"quick-visit-refine/*",
						"quick-visit-output/*",
						"quick-visit-emails/*",
						"medications/*"
					]
				}
			}
		}
	]
})
}


# Identity Pool Role Attachment

resource "aws_cognito_identity_pool_roles_attachment" "this" {
  identity_pool_id = aws_cognito_identity_pool.this.id

  roles = {
    authenticated = aws_iam_role.authenticated.arn
  }
}