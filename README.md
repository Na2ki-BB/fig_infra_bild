# fig_infra_bild

AWS 上に Web アプリケーションを再現性高く構築するための Terraform リポジトリです。

初回は手動構築で検証し、二回目以降はこのリポジトリの Terraform で同じ構成を作れる状態にすることを目的にしています。

## Repository Layout

```text
.
├── docs/
│   └── MVP.md                # まず Terraform 化する最小範囲
└── terraform/
    ├── envs/
    │   └── dev/              # 開発・検証環境
    └── modules/              # 再利用する Terraform module 置き場
```

## Current Status

- 手動構築した AWS 構成を棚卸しする段階です。
- Terraform は AWS provider と dev 環境の最小骨格のみ用意しています。
- 実リソースの追加は手動構築内容を確認してから進めます。

## Local Workflow

```bash
cd terraform/envs/dev
terraform init
terraform fmt -recursive ../..
terraform validate
terraform plan
```

AWS 認証情報は環境変数、AWS CLI profile、または SSO など、Terraform AWS provider が認識できる方法で設定します。

## Next Steps

1. 手動構築済み AWS リソースを棚卸しする。
2. Terraform state の置き場所を決める。
3. dev 環境から Terraform 化する。
4. `terraform plan` と実環境差分を見ながら、手動構築との差を潰す。
