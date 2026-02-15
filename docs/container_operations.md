# Docker コンテナ運用ガイド

このリポジトリでは dbt と Terraform を Docker コンテナで実行する。

## 前提
- Docker と Docker Compose が利用可能
- ホストの `~/.aws` に認証情報が設定済み
- `.env` が `.env.example` を基に作成済み（環境切替は `APP_ENV` で制御）

## 構成
- `docker/dbt/Dockerfile`: dbt 実行用
- `docker/terraform/Dockerfile`: Terraform 実行用
- `docker-compose.yml`: 2コンテナ構成

## 実行方法（ラッパー）
- dbt: `scripts/run_in_container.sh dbt`
- Terraform: `scripts/run_in_container.sh terraform-plan`

## dbt の準備と実行
1. `configs/dbt/profiles.yml.example` を基に `configs/dbt/profiles.yml` を作成する。
2. `scripts/run_in_container.sh dbt` を実行する。

## 環境の切り替え
- `.env` の `APP_ENV` を `dev` / `prod` に切り替える。
- 詳細は `docs/env_usage.md` を参照する。

## Terraform の準備と実行
1. `configs/terraform_backend.hcl.example` を基に `configs/terraform_backend.hcl` を作成する。
2. `scripts/run_in_container.sh terraform-plan` を実行する。
   - `APP_ENV` に応じて `packages/infra/env/${APP_ENV}.tfvars` が読み込まれる。

## Ingestion の実行
- `scripts/run_ingestion.sh` を実行する。

## 補足
- 実行前チェックは `docs/setup_checklist.md` を参照する。
