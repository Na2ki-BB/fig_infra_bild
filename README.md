# fig_infra_bild

Terraform infrastructure for running `form_invoice_generator` on AWS.

The application source code lives in a separate repository.

```text
Application:
  https://github.com/Na2ki-BB/form_invoice_generator.git

Infrastructure:
  this repository
```

This repository does not contain application code. It manages the AWS infrastructure needed for the application, including networking, database, ECS, API Gateway, Cognito, and Amplify.

## What This Creates

`terraform/envs/dev` is the Terraform root module for the development/test AWS environment.

Main architecture:

```text
Browser
  -> Amplify Hosting
  -> API Gateway HTTP API
  -> API Gateway VPC Link
  -> Internal ALB
  -> ECS Fargate API task
  -> RDS PostgreSQL
```

Main AWS resources defined by Terraform:

- VPC, private subnets, and private route table
- Security Groups
- VPC Endpoints for ECR, CloudWatch Logs, Secrets Manager, and S3
- RDS PostgreSQL
- Secrets Manager secret metadata for the application `DATABASE_URL`
- ECR repositories for API and migration images
- CloudWatch log groups
- IAM roles for ECS tasks
- Internal ALB and target group
- ECS cluster, task definitions, and API service
- Cognito User Pool, App Client, and hosted domain
- API Gateway HTTP API, routes, VPC Link, and JWT authorizer
- Amplify App and branch for the frontend

## What This Does Not Do

This repository does not:

- contain the application source code
- build or push Docker images automatically
- write actual secret values such as `DATABASE_URL`
- run database migrations automatically
- manage a custom domain or ACM certificate
- configure a shared Terraform backend
- store GitHub tokens or AWS credentials

Do not commit secrets, Terraform state, plan files, or local override files.

## Repository Layout

```text
.
├── README.md
├── docs/
│   └── MVP.md
└── terraform/
    └── envs/
        └── dev/
            ├── versions.tf
            ├── providers.tf
            ├── variables.tf
            ├── main.tf
            ├── network.tf
            ├── security-groups.tf
            ├── vpc-endpoints.tf
            ├── rds.tf
            ├── ecr.tf
            ├── logs.tf
            ├── iam.tf
            ├── alb.tf
            ├── ecs.tf
            ├── cognito.tf
            ├── api-gateway.tf
            ├── amplify.tf
            └── outputs.tf
```

## Prerequisites

Install and configure:

- Terraform `>= 1.6.0, < 2.0.0`
- AWS CLI
- AWS credentials for the target AWS account
- Docker, if you will build and push application images
- access to `https://github.com/Na2ki-BB/form_invoice_generator.git`

Before running Terraform against a real AWS account, confirm the active account.

```bash
aws sts get-caller-identity
```

## Terraform Workflow

Run commands from this repository root.

```bash
terraform -chdir=terraform/envs/dev init
terraform fmt -recursive terraform
terraform -chdir=terraform/envs/dev validate
terraform -chdir=terraform/envs/dev plan
```

To create real AWS resources, review the plan carefully and then run:

```bash
terraform -chdir=terraform/envs/dev apply
```

Do not run `apply` unless you intend to create billable AWS resources.

## Local Overrides

Default values live in:

```text
terraform/envs/dev/variables.tf
```

For local changes, create:

```text
terraform/envs/dev/terraform.tfvars
```

`terraform.tfvars` is ignored by Git.

Example:

```hcl
aws_region = "ap-northeast-1"

# Use 0 if images, secrets, or migrations are not ready yet.
api_desired_count = 0

amplify_repository_url = "https://github.com/Na2ki-BB/form_invoice_generator.git"
```

Do not put passwords, tokens, AWS keys, or full database URLs in `terraform.tfvars`.

## Amplify Repository Access

Amplify is configured to build the frontend from:

```text
https://github.com/Na2ki-BB/form_invoice_generator.git
```

The frontend app root is:

```text
frontend
```

GitHub repository URLs are configuration values. GitHub tokens are secrets.

This repository does not commit an Amplify GitHub token. If Amplify requires repository authorization during real deployment, connect the repository through a non-committed method, such as the Amplify GitHub App or another secure token workflow.

## After Creating Infrastructure

If you create the infrastructure, the application still needs runtime artifacts and secrets.

### 1. Build and Push Images

Terraform creates ECR repositories, but it does not push Docker images.

Useful outputs:

```bash
terraform -chdir=terraform/envs/dev output api_ecr_repository_url
terraform -chdir=terraform/envs/dev output migration_ecr_repository_url
```

The application repository contains:

```text
backend/Dockerfile
deploy/migrations/Dockerfile
```

Build and push the API image and migration image to the ECR repository URLs from Terraform output.

### 2. Set the DATABASE_URL Secret

Terraform creates the Secrets Manager secret container for the application `DATABASE_URL`, but it does not write the actual secret value.

Useful outputs:

```bash
terraform -chdir=terraform/envs/dev output rds_endpoint
terraform -chdir=terraform/envs/dev output rds_port
terraform -chdir=terraform/envs/dev output rds_db_name
terraform -chdir=terraform/envs/dev output rds_master_username
terraform -chdir=terraform/envs/dev output app_database_url_secret_arn
```

Write the real `DATABASE_URL` value through AWS Console, AWS CLI, or a secure deployment workflow.

Do not paste the database password into Git, README files, issue comments, pull requests, or Terraform files.

### 3. Run Migrations

Terraform defines the migration ECS task definition, but it does not run migrations automatically.

Run the migration task only after:

- RDS is available
- the migration image has been pushed to ECR
- the `DATABASE_URL` secret value exists
- networking and security groups are in place

### 4. Start the API Service

If you first created the service with:

```hcl
api_desired_count = 0
```

change it to:

```hcl
api_desired_count = 1
```

Then run:

```bash
terraform -chdir=terraform/envs/dev plan
terraform -chdir=terraform/envs/dev apply
```

## Verification

Useful outputs:

```bash
terraform -chdir=terraform/envs/dev output amplify_branch_url
terraform -chdir=terraform/envs/dev output api_gateway_endpoint
terraform -chdir=terraform/envs/dev output cognito_domain
```

Basic API health check:

```bash
curl -i "$(terraform -chdir=terraform/envs/dev output -raw api_gateway_endpoint)/health"
```

Open the Amplify URL in a browser and check:

```text
/
/admin
/admin/login
/admin/auth/callback
```

SPA routes should return the React app, not a hosting 404.

## Cost Notes

The dev environment contains billable resources, including:

- RDS
- Internal ALB
- Interface VPC Endpoints
- ECS Fargate tasks
- Amplify Hosting builds
- CloudWatch Logs
- Secrets Manager
- ECR storage

Destroy resources when they are no longer needed:

```bash
terraform -chdir=terraform/envs/dev destroy
```

Review the destroy plan before approving it.

## Git Safety

The repository ignores local and sensitive files such as:

```text
**/.terraform/
*.tfstate
*.tfplan
terraform.tfvars
*.auto.tfvars
*.env
*.key
*.pem
.codex-notes/
learning/
```

Before committing, check:

```bash
git status --short
git diff
```

Do not commit:

- Terraform state
- Terraform plan files
- AWS account secrets
- GitHub tokens
- database passwords
- actual `DATABASE_URL` values
