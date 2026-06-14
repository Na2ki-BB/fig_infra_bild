# MVP

This document defines the current dev-environment MVP for this infrastructure repository.

The application source code lives in a separate repository:

```text
https://github.com/Na2ki-BB/form_invoice_generator.git
```

This repository provides Terraform infrastructure for running that application on AWS.

## Objective

Define the AWS dev infrastructure needed to run `form_invoice_generator` with Terraform.

The Terraform configuration is intended to be reusable by someone who wants to deploy the application repository on AWS. It is not the application repository itself.

## Current Scope

The MVP dev architecture is:

```text
Browser
  -> Amplify Hosting
  -> API Gateway HTTP API
  -> API Gateway VPC Link
  -> Internal ALB
  -> ECS Fargate API task
  -> RDS PostgreSQL
```

Supporting services:

```text
Cognito
ECR
CloudWatch Logs
IAM
Secrets Manager
VPC Endpoints
```

## Included Terraform Resources

The MVP includes Terraform definitions for:

- VPC, private subnets, and private route table
- Security Groups
- Interface VPC Endpoints for ECR, CloudWatch Logs, and Secrets Manager
- S3 Gateway VPC Endpoint
- RDS PostgreSQL
- Secrets Manager secret metadata for application `DATABASE_URL`
- ECR repositories for API and migration images
- CloudWatch log groups
- ECS IAM roles
- Internal ALB, listener, and target group
- ECS cluster, API task definition, migration task definition, and API service
- Cognito User Pool, App Client, and hosted domain
- API Gateway HTTP API, routes, VPC Link, integration, stage, and JWT authorizer
- Amplify App and branch for the frontend

## Not Included

The MVP does not include:

- application source code
- automatic Docker image build or push
- actual secret values such as `DATABASE_URL`
- automatic database migration execution
- custom domain management
- ACM certificate management
- production environment
- shared Terraform backend
- full CI/CD pipeline
- monitoring dashboards or alerting

## Completion Criteria

This MVP is considered complete when:

- Terraform resources are defined under `terraform/envs/dev`.
- `terraform fmt -recursive terraform` succeeds.
- `terraform -chdir=terraform/envs/dev validate` succeeds.
- `terraform -chdir=terraform/envs/dev plan` produces the expected create-only plan.
- README explains how another user can use this infrastructure repository with the separate application repository.
- Secrets, Terraform state, plan files, and local override files are not committed.

## Current Status

The Terraform draft for the dev environment is complete for the learning/reproduction goal.

The repository is not yet a full production deployment system. To use it for a real deployment, the user still needs to handle:

- AWS account and credential setup
- Terraform state ownership
- Docker image build and push
- application `DATABASE_URL` secret value
- database migrations
- runtime verification
- cost cleanup
