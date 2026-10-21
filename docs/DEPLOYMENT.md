# 初回デプロイ手順（dev）

対象は `terraform/envs/dev` と、変更していない別リポジトリ
[`form_invoice_generator`](https://github.com/Na2ki-BB/form_invoice_generator) です。
アプリ確認基準の commit は `1173a0e9573937039d97a65efa19db5348869149`。
別の commit を使う場合は Dockerfile、migration、環境変数を再確認してください。

この文書は実行手順であり、AWS 上でのデプロイ成功を保証するものではありません。
`apply`、image push、secret 登録、task 実行、Amplify build は実リソース・費用に影響します。
実行前に AWS account、region、plan、費用と権限を確認してください。
既存 DB への初期化や、既存環境への新規構築手順の流用は禁止です。

## 0. 準備と安全上の注意

- Terraform `>= 1.6.0, < 2.0.0`、AWS CLI v2、Docker Buildx、Git、Bash、jq を用意します。
- `.terraform.lock.hcl` を使い、意図せず provider を upgrade しません。
- 対象 account への既存の認証方法（SSO/profile 等）を使います。credential を Git に書きません。
- state は初期設定ではローカルです。限定したアクセス権と安全なバックアップを確保し、同時実行しません。
- `sensitive = true` は画面表示を隠すだけです。GitHub token は Terraform state / saved plan に残り得ます。
  state、plan、バックアップ、デバッグログを公開・コミットしないでください。`TF_LOG` / `set -x` は使いません。
- 既定の `api_stage_name = "$default"`、port、`app_auth_mode = "trusted_gateway"` を前提にします。
  Cognito domain prefix は region 内で一意なものにします。

以降はインフラリポジトリのルートをカレントディレクトリにし、同じ Bash セッションで実行します。

```bash
set -euo pipefail
export AWS_REGION=ap-northeast-1
export AWS_DEFAULT_REGION="$AWS_REGION"
export AWS_PAGER=""
aws sts get-caller-identity
```

`terraform/envs/dev/terraform.tfvars` に非秘密の設定を記載します。初回は必ず task 数を 0 にします。
次のタグは後の Docker build / push と一致させます。一度使った release tag は上書きしないでください。

```hcl
aws_region            = "ap-northeast-1"
api_desired_count     = 0
api_image_tag         = "bootstrap-1173a0e"
migration_image_tag   = "bootstrap-1173a0e"
cognito_domain_prefix = "replace-with-your-unique-fig-dev-prefix"
```

## 1. Amplify の GitHub 接続

### 新しい Amplify App を Terraform で作る場合

1. AWS の [GitHub 接続手順](https://docs.aws.amazon.com/amplify/latest/userguide/setting-up-GitHub-access.html#setting-up-github-app-cloudformation)
   に従い、対象 region の Amplify GitHub App を必要なアプリリポジトリだけに許可します。
2. 同手順に沿った短命の setup token を用意します。現在の AWS 手順は classic PAT の `admin:repo_hook` を案内しています。
   組織の制約がある場合は管理者の承認が必要です。token の作成・権限付与は本人が確認して行います。
3. token をファイルやコマンド引数に直書きせず、非表示の入力から環境変数へ渡します。

```bash
read -r -s -p "Amplify GitHub setup token: " TF_VAR_amplify_github_access_token
printf '\n'
export TF_VAR_amplify_github_access_token
test -n "$TF_VAR_amplify_github_access_token"
```

新規作成時は `amplify_github_access_token` が必要です。`null` のままでも静的 validate は通りますが、
GitHub 接続付き App の新規作成は成功しません。token は Amplify の build 環境変数には渡しません。

接続成立後は環境変数を unset し、setup token を失効させます。
`access_token` は setup 専用として `ignore_changes` しているため、通常の更新で空 token を送りません。
この設定は過去の state / plan 内の token を消去するものではありません。
再接続は Amplify Console で行い、App の再作成・置換時は有効な setup token を改めて渡してください。

### 接続済み App がすでに存在する場合

token を Terraform に渡したくない場合は、Console で接続した App を import する方法もあります。
App の ID、対象 repository と branch を本人が確認し、二重作成しないでください。
branch も既存なら両方 import します。branch が未作成なら branch の import は不要です。

```bash
terraform -chdir=terraform/envs/dev init -lockfile=readonly
terraform -chdir=terraform/envs/dev import aws_amplify_app.frontend '<existing-app-id>'
terraform -chdir=terraform/envs/dev import aws_amplify_branch.main '<existing-app-id>/<branch-name>'
```

import 後は token を未設定（`null`）にできます。plan で build 設定・環境変数・redirect の差分を必ず確認します。
単に GitHub App を install しただけでは、未作成の Amplify App の token を省略できません。

## 2. インフラを作成する（API task 数 0）

```bash
terraform -chdir=terraform/envs/dev init -lockfile=readonly
terraform fmt -check -recursive terraform
terraform -chdir=terraform/envs/dev validate
terraform -chdir=terraform/envs/dev plan -out=bootstrap.tfplan
# 対象 account と差分を確認した場合のみ実行する
terraform -chdir=terraform/envs/dev apply bootstrap.tfplan
unset TF_VAR_amplify_github_access_token
```

`bootstrap.tfplan` は `terraform/envs/dev` に保存されます。秘密として扱い、不要になれば安全に破棄します。
RDS、endpoint、ALB 等の作成が完了したことを確認します。task 数 0 なので、この時点の API 503 は異常とは限りません。
Amplify の最初の build が完了していても、API と DB の準備完了を意味しません。

## 3. API / migration image を build・push する

アプリの Dockerfile は API が `backend` context、migration がリポジトリ root context です。
Fargate の既定 CPU architecture に合わせて `linux/amd64` を明示します。Apple Silicon でも省略しません。

```bash
# 未取得の場合。既存 checkout がある場合はその絶対パスを APP_DIR に設定する
git clone https://github.com/Na2ki-BB/form_invoice_generator.git ../form_invoice_generator
APP_DIR="$(cd ../form_invoice_generator && pwd)"
git -C "$APP_DIR" checkout 1173a0e9573937039d97a65efa19db5348869149
git -C "$APP_DIR" status --short

IMAGE_TAG=bootstrap-1173a0e
API_REPO="$(terraform -chdir=terraform/envs/dev output -raw api_ecr_repository_url)"
MIGRATION_REPO="$(terraform -chdir=terraform/envs/dev output -raw migration_ecr_repository_url)"
REGISTRY="${API_REPO%%/*}"
aws ecr get-login-password --region "$AWS_REGION" |
  docker login --username AWS --password-stdin "$REGISTRY"

docker buildx build --platform linux/amd64 --load \
  -t "$API_REPO:$IMAGE_TAG" -f "$APP_DIR/backend/Dockerfile" "$APP_DIR/backend"
docker buildx build --platform linux/amd64 --load \
  -t "$MIGRATION_REPO:$IMAGE_TAG" -f "$APP_DIR/deploy/migrations/Dockerfile" "$APP_DIR"
docker push "$API_REPO:$IMAGE_TAG"
docker push "$MIGRATION_REPO:$IMAGE_TAG"
docker logout "$REGISTRY"
```

ECR で両タグの存在と digest を確認します。ECS task definition の image tag も同じ値であることを確認してください。
`latest` を上書きしただけでは ECS service の rollout は発生しません。
将来の更新も別タグを push し、tfvars のタグを変更して plan / apply します。

## 4. DATABASE_URL の実値を登録する

Terraform は secret の「入れ物」しか作りません。次の output から対象を確認します。

```bash
terraform -chdir=terraform/envs/dev output -raw rds_master_user_secret_arn
terraform -chdir=terraform/envs/dev output -raw app_database_url_secret_arn
terraform -chdir=terraform/envs/dev output -raw rds_endpoint
terraform -chdir=terraform/envs/dev output -raw rds_db_name
terraform -chdir=terraform/envs/dev output rds_port
```

1. AWS Secrets Manager Console で RDS 管理の master secret を確認します。
   secret の password と username、上の RDS endpoint / port / DB 名を使います。
2. アプリ用 secret（`app_database_url_secret_arn`）に、次の形の URI を「プレーンテキスト」で登録します。
   JSON の `{ "DATABASE_URL": ... }` ではありません。ECS は SecretString 全体を環境変数に渡します。

   `postgres://<encoded-username>:<encoded-password>@<rds-endpoint>:5432/<db-name>?sslmode=require`

3. username / password 中の `@`、`:`, `/`、`%`、`#` 等は URI percent-encoding します。
   完全な URI、password をチャット、Git、ログ、shell history、Terraform に貼らないでください。
   接続値の組み立ては信頼できるローカル環境で行い、オンラインの URL encoder を使いません。
4. `AWSCURRENT` の値が設定されたことを確認します。secret 値自体を共有する必要はありません。

`sslmode=require` は通信暗号化を要求しますが、CA / hostname 検証まで有効にする設定ではありません。
本番向けの証明書検証・専用 DB user の設計はこの dev 手順の範囲外です。

RDS 管理 secret は rotation される可能性があります。コピーしたアプリ用 URI は自動同期されません。
rotation 時は URI を安全に更新し、API task を再起動して接続確認してください。

## 5. 空 DB の初期化 task を 1 回実行する

現アプリの migration runner は全 SQL を順に実行します。履歴テーブルや再実行制御はありません。
`CREATE TABLE` 等は非冪等なので、成功後の再実行や、途中失敗後の盲目的な再実行はしません。
失敗時はログと DB の適用済み SQL を調べ、API を起動せず復旧方針を決めてください。

```bash
CLUSTER="$(terraform -chdir=terraform/envs/dev output -raw ecs_cluster_name)"
MIGRATION_TASK="$(terraform -chdir=terraform/envs/dev output -raw migration_task_definition_arn)"
SUBNETS="$(terraform -chdir=terraform/envs/dev output -json private_subnet_ids)"
ECS_SG="$(terraform -chdir=terraform/envs/dev output -raw ecs_security_group_id)"
NETWORK="$(jq -cn --argjson subnets "$SUBNETS" --arg sg "$ECS_SG" \
  '{awsvpcConfiguration:{subnets:$subnets,securityGroups:[$sg],assignPublicIp:"DISABLED"}}')"

RUN_RESULT="$(aws ecs run-task --cluster "$CLUSTER" --launch-type FARGATE \
  --task-definition "$MIGRATION_TASK" --network-configuration "$NETWORK" --output json)"
printf '%s\n' "$RUN_RESULT" | jq -e '.failures | length == 0' >/dev/null
TASK_ARN="$(printf '%s\n' "$RUN_RESULT" | jq -er '.tasks[0].taskArn')"
printf 'Migration task: %s\n' "$TASK_ARN"
aws ecs wait tasks-stopped --cluster "$CLUSTER" --tasks "$TASK_ARN"
RESULT="$(aws ecs describe-tasks --cluster "$CLUSTER" --tasks "$TASK_ARN" --output json)"
printf '%s\n' "$RESULT" | jq '{failures, tasks: [.tasks[] | {stopCode, stoppedReason, containers}]}'
printf '%s\n' "$RESULT" | jq -e \
  '(.failures | length == 0) and (.tasks | length == 1) and
   (.tasks[0].containers | length > 0) and all(.tasks[0].containers[]; .exitCode == 0)' >/dev/null
```

`STOPPED` は成功を意味しません。exit code 0 と CloudWatch の
`Database migrations completed.` を確認してから次へ進みます。
waiter が timeout した場合も、上の task ARN を保存して同じ task を確認し、重複起動しないでください。
ロググループ名は `terraform ... output -raw migration_log_group_name` で取得できます。

## 6. API service と Amplify build を起動・確認する

tfvars の `api_desired_count` だけを `1` に変更します。両 image tag は push 済みの値を維持します。

```bash
terraform -chdir=terraform/envs/dev plan -out=activate.tfplan
# task 数と意図した差分だけであることを確認して実行する
terraform -chdir=terraform/envs/dev apply activate.tfplan
SERVICE="$(terraform -chdir=terraform/envs/dev output -raw api_service_name)"
aws ecs wait services-stable --cluster "$CLUSTER" --services "$SERVICE"
aws elbv2 describe-target-health \
  --target-group-arn "$(terraform -chdir=terraform/envs/dev output -raw api_target_group_arn)"

API_URL="$(terraform -chdir=terraform/envs/dev output -raw api_gateway_endpoint)"
curl --fail-with-body "$API_URL/health"
curl -sS -o /dev/null -w '%{http_code}\n' "$API_URL/admin/products"
```

service の running count が 1、ALB target が healthy、`/health` が 200 / `ok`、
未認証の `/admin/products` が 401 であることを確認します。`/health` だけでは DB 操作の成功を確認できません。

Amplify Console で対象 branch の build を確認します。Terraform の branch 作成だけで最初の build が
始まっていない場合は、設定を確認して Console の「Deploy / Redeploy」または次を実行します。

```bash
aws amplify start-job \
  --app-id "$(terraform -chdir=terraform/envs/dev output -raw amplify_app_id)" \
  --branch-name "$(terraform -chdir=terraform/envs/dev output -raw amplify_branch_name)" \
  --job-type RELEASE
```

build 成功を確認し、branch の `VITE_*` が Terraform の API / Cognito output と一致することを確認します。
これらは frontend に build 時に埋め込まれるため、変更時には再 build が必要です。

## 7. Cognito 管理者を作り、画面から動作確認する

`cognito_user_pool_id` の User Pool を AWS Console で開き、管理画面を使う本人の email で user を作成します。
このプールは管理者による user 作成のみ許可しています。招待・仮 password の受け渡しは安全な方法で行い、
本人が Hosted UI の初回ログインで password を変更します。password を Git や Terraform に置きません。
この構成にはアプリ内の役割分離がないため、無関係な利用者をこの管理者 pool に追加しないでください。

- `amplify_branch_url` の `/admin/login` から Cognito にログインできる。
- `/admin/auth/callback` 経由で `/admin` に戻り、商品・フォーム・注文の一覧取得が成功する。
- `/`、`/admin`、`/admin/login` の直接アクセス・再読み込みで hosting 404 にならない。
- `/admin/auth/callback` の直接アクセスでは SPA が表示され、code/state 不足のエラーを安全に表示する。
- テスト用フォームで送信、管理画面で一覧確認、請求書ダウンロードを行い、DB 操作まで確認する。
- logout 後に管理画面へ戻っても認証を要求する。ブラウザの Console / Network と API ログに異常がない。

## トラブル時の確認順序

- Amplify の token エラー: 新規作成 / import の区別、GitHub App の region・repository 許可、setup token を確認。
- `CannotPullContainerError`: image tag と CPU architecture、ECR api / dkr endpoint、S3 gateway route、
  ECS SG の S3 prefix list 宛 TCP 443 を確認。endpoint SG 宛 443 だけでは image layer を取得できません。
- `ResourceInitializationError`: secret に `AWSCURRENT` があるか、execution role の権限、Secrets Manager / Logs endpoint を確認。
- migration 失敗: task exit code と CloudWatch を確認。SQL を繰り返し実行しない。
- API 5xx: service events、target health、API ログ、DB URI と rotation を確認。
- UI の認証 / CORS エラー: Amplify branch URL、callback / logout URL、VITE 値、再 build、API Gateway JWT 設定を確認。

## 検証と片付け

AWS にアクセスしない検証:

```bash
terraform -chdir=terraform/envs/dev init -backend=false -lockfile=readonly
terraform fmt -check -recursive terraform
terraform -chdir=terraform/envs/dev validate
# この mock test だけ Terraform >= 1.7 が必要。全 AWS provider を mock し、実 AWS は変更しない
terraform -chdir=terraform/envs/dev test -test-directory=tests_mock
```

mock test は token の受け渡し、既存接続後の token 省略、空 token の拒否、S3 宛の限定 egress、
private route と初期 task 数を検証します。IAM の実権限、AWS account の制約、実際の GitHub 接続、
Docker / DB / UI の実行結果を保証しません。実環境の plan と上の受け入れ確認は別途必要です。

不要時は費用を確認して片付けます。ただし既定の RDS deletion protection は有効です。
削除するなら DB の退避方法を先に決めてください。この構成は `skip_final_snapshot = true` なので、
保護を無効にした後の destroy では最終 snapshot を自動作成しません。
ECR に image があると repository 削除も止まる場合があります。削除を安易に自動化しないでください。

参考:
- [AWS provider 5.100.0 Amplify App](https://github.com/hashicorp/terraform-provider-aws/blob/v5.100.0/website/docs/r/amplify_app.html.markdown)
- [ECR の VPC endpoint](https://docs.aws.amazon.com/AmazonECR/latest/userguide/vpc-endpoints.html)
- [Gateway endpoint の security group](https://docs.aws.amazon.com/vpc/latest/privatelink/gateway-endpoints.html#gateway-endpoint-security)
