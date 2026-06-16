# fig_infra_bild

`form_invoice_generator` を AWS 上で動かすための Terraform インフラリポジトリです。

アプリケーション本体のソースコードは、別リポジトリにあります。

```text
アプリケーション:
  https://github.com/Na2ki-BB/form_invoice_generator.git

インフラ:
  このリポジトリ
```

このリポジトリにはアプリケーションコードは含まれていません。ネットワーク、データベース、ECS、API Gateway、Cognito、Amplify など、アプリケーションを動かすために必要な AWS インフラを管理します。

## 作成するもの

`terraform/envs/dev` は、開発・検証用 AWS 環境の Terraform root module です。

主な構成は次の通りです。

```text
Browser
  -> Amplify Hosting
  -> API Gateway HTTP API
  -> API Gateway VPC Link
  -> Internal ALB
  -> ECS Fargate API task
  -> RDS PostgreSQL
```

Terraform で定義している主な AWS リソースは次の通りです。

- VPC、private subnet、private route table
- Security Group
- ECR、CloudWatch Logs、Secrets Manager、S3 用の VPC Endpoint
- RDS PostgreSQL
- アプリケーション用 `DATABASE_URL` の Secrets Manager secret metadata
- API image と migration image 用の ECR repository
- CloudWatch log group
- ECS task 用の IAM role
- Internal ALB と target group
- ECS cluster、task definition、API service
- Cognito User Pool、App Client、hosted domain
- API Gateway HTTP API、route、VPC Link、JWT authorizer
- frontend 用の Amplify App と branch

## このリポジトリで行わないこと

このリポジトリでは、次のことは行いません。

- アプリケーション本体の実装
- Docker image の自動 build / push
- `DATABASE_URL` などの secret 実値の書き込み
- database migration の自動実行
- custom domain や ACM certificate の管理
- shared Terraform backend の設定
- GitHub token や AWS credential の保存

secret、Terraform state、plan file、local override file はコミットしないでください。

## ディレクトリ構成

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

## 前提

次のものを用意してください。

- Terraform `>= 1.6.0, < 2.0.0`
- AWS CLI
- 対象 AWS account の認証情報
- Docker。アプリケーション image を build / push する場合に必要です
- `https://github.com/Na2ki-BB/form_invoice_generator.git` へのアクセス権

実際の AWS account に対して Terraform を実行する前に、操作対象の account を確認してください。

```bash
aws sts get-caller-identity
```

## Terraform の基本操作

コマンドは、このリポジトリのルートで実行します。

```bash
terraform -chdir=terraform/envs/dev init
terraform fmt -recursive terraform
terraform -chdir=terraform/envs/dev validate
terraform -chdir=terraform/envs/dev plan
```

実際に AWS リソースを作成する場合は、`plan` の内容をよく確認してから実行します。

```bash
terraform -chdir=terraform/envs/dev apply
```

`apply` は課金対象の AWS リソースを作成します。実際に作成する意図がある場合だけ実行してください。

## ローカルで値を上書きする場合

デフォルト値は次のファイルにあります。

```text
terraform/envs/dev/variables.tf
```

ローカルで値を上書きする場合は、次のファイルを作成します。

```text
terraform/envs/dev/terraform.tfvars
```

`terraform.tfvars` は Git 管理対象外です。

例:

```hcl
aws_region = "ap-northeast-1"

# image、secret、migration の準備ができていない場合は 0 にします。
api_desired_count = 0

amplify_repository_url = "https://github.com/Na2ki-BB/form_invoice_generator.git"
```

`terraform.tfvars` に password、token、AWS key、完全な database URL を書かないでください。

## Amplify の GitHub 接続

Amplify は次のリポジトリから frontend を build する設定です。

```text
https://github.com/Na2ki-BB/form_invoice_generator.git
```

frontend の app root は次の通りです。

```text
frontend
```

GitHub repository URL は設定値です。GitHub token は secret です。

このリポジトリには Amplify 用の GitHub token をコミットしません。実デプロイ時に Amplify 側で repository authorization が必要な場合は、Amplify GitHub App やその他の安全な token 管理など、コミットされない方法で接続してください。

## インフラ作成後に必要な作業

インフラを作成した後も、アプリケーションを動かすには runtime artifact と secret が別途必要です。

### 1. Docker image を build / push する

Terraform は ECR repository を作成しますが、Docker image は push しません。

ECR repository URL は output で確認できます。

```bash
terraform -chdir=terraform/envs/dev output api_ecr_repository_url
terraform -chdir=terraform/envs/dev output migration_ecr_repository_url
```

アプリケーションリポジトリには、次の Dockerfile があります。

```text
backend/Dockerfile
deploy/migrations/Dockerfile
```

Terraform output の ECR repository URL に対して、API image と migration image を build / push してください。

### 2. DATABASE_URL secret を設定する

Terraform はアプリケーション用 `DATABASE_URL` の Secrets Manager secret container を作成しますが、実際の secret value は書き込みません。

必要な output は次のコマンドで確認できます。

```bash
terraform -chdir=terraform/envs/dev output rds_endpoint
terraform -chdir=terraform/envs/dev output rds_port
terraform -chdir=terraform/envs/dev output rds_db_name
terraform -chdir=terraform/envs/dev output rds_master_username
terraform -chdir=terraform/envs/dev output app_database_url_secret_arn
```

実際の `DATABASE_URL` は、AWS Console、AWS CLI、または安全なデプロイ手順で設定してください。

database password を Git、README、issue、pull request、Terraform file に貼らないでください。

### 3. migration を実行する

Terraform は migration 用の ECS task definition を定義しますが、migration は自動実行しません。

migration は、次の準備ができた後に実行してください。

- RDS が available になっている
- migration image が ECR に push されている
- `DATABASE_URL` secret value が設定されている
- network と security group が作成済みである

### 4. API service を起動する

最初に次の設定で作成した場合、

```hcl
api_desired_count = 0
```

API task を起動するには、次のように変更します。

```hcl
api_desired_count = 1
```

その後、次のコマンドを実行します。

```bash
terraform -chdir=terraform/envs/dev plan
terraform -chdir=terraform/envs/dev apply
```

## 動作確認

主な URL は output で確認できます。

```bash
terraform -chdir=terraform/envs/dev output amplify_branch_url
terraform -chdir=terraform/envs/dev output api_gateway_endpoint
terraform -chdir=terraform/envs/dev output cognito_domain
```

API health check の例です。

```bash
curl -i "$(terraform -chdir=terraform/envs/dev output -raw api_gateway_endpoint)/health"
```

Amplify URL をブラウザで開き、次の path を確認します。

```text
/
/admin
/admin/login
/admin/auth/callback
```

SPA route では hosting 404 ではなく React app が返る必要があります。

## 費用に関する注意

dev 環境には、次のような課金対象リソースが含まれます。

- RDS
- Internal ALB
- Interface VPC Endpoint
- ECS Fargate task
- Amplify Hosting build
- CloudWatch Logs
- Secrets Manager
- ECR storage

不要になったリソースは削除してください。

```bash
terraform -chdir=terraform/envs/dev destroy
```

`destroy` も実行前に plan 内容を確認してください。

## Git に入れてはいけないもの

このリポジトリでは、次のような local file や secret file を ignore しています。

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

コミット前に確認してください。

```bash
git status --short
git diff
```

コミットしてはいけないもの:

- Terraform state
- Terraform plan file
- AWS account secret
- GitHub token
- database password
- 実際の `DATABASE_URL`
