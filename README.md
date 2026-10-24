├── config
│   ├── dev
│   │   ├── Jenkinsfile
│   │   └── terraform.tfvars
│   ├── prod
│   │   ├── Jenkinsfile
│   │   └── terraform.tfvars
│   └── qa
│       ├── Jenkinsfile
│       └── terraform.tfvars
│
├── src
│   ├── modules
│   │   ├── api_gateway
│   │   ├── appsync
│   │   ├── aurora
│   │   ├── cognito
│   │   ├── iam
│   │   ├── lambda
│   │   ├── lambda_layers
│   │   ├── parameterstore
│   │   ├── rds
│   │   ├── s3
│   │   ├── sqs
│   │   └── vpc
│   │
│   ├── main.tf
│   ├── provider.tf
│   ├── terraform.tfvars
│   ├── variables.tf
│   └── .terraform.lock.hcl
│
├── .gitignore
└── README.md
