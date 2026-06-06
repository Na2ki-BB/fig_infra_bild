# MVP

## Objective

Terraform で dev 環境を一度作成し、手動構築済み AWS 環境と同等の最小 Web アプリケーション公開経路を再現する。

## Definition of Done

- `terraform/envs/dev` に実リソース定義がある。
- `terraform fmt -recursive terraform` が通る。
- `terraform validate` が通る。
- `terraform plan` の差分を説明できる。
- Web アプリケーションの公開 URL または DNS 名にアクセスできる。
- 手動構築リソースを import した場合、import 手順が記録されている。

## Phase 1: Discovery

- 手動構築済み AWS リソースを棚卸しする。
- アプリケーションの実行方式を確認する。
- 必要な環境変数、シークレット、ポート、ヘルスチェックパスを確認する。
- Terraform state backend を決める。

## Phase 2: Terraform Foundation

- AWS provider と version constraints を固定する。
- dev 環境 root module を整える。
- 共通タグ、命名規則、基本変数を定義する。
- `.gitignore` で Terraform の生成物と秘密情報を除外する。

## Phase 3: First Deployable Infra

選択した実行方式に応じて、最小構成を作る。

| Runtime | Minimum resources |
| --- | --- |
| Static site | S3 bucket, CloudFront distribution, ACM certificate if custom domain is used. |
| App Runner | Service, ECR or source connection, environment variables, IAM role if needed. |
| ECS Fargate | VPC, subnets, ALB, ECS cluster, service, task definition, logs, IAM roles. |
| Lambda API | Lambda function, API Gateway, IAM role, logs, custom domain if needed. |
| EC2 | VPC/security group, instance, IAM role, logs, optional ALB. |

## Deferred

- Production environment
- Full CI/CD
- Blue/green deployment
- Advanced observability
- WAF and detailed threat controls
- Cost dashboards and budgets
