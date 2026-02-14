# Docker コンテナ運用ガイド

このリポジトリでは dbt と Terraform を Docker コンテナで実行する。

## 前提
- Docker と Docker Compose が利用可能
- ホストの `~/.aws` に認証情報が設定済み

## 構成
- `docker/dbt/Dockerfile`: dbt 実行用
- `docker/terraform/Dockerfile`: Terraform 実行用
- `docker-compose.yml`: 2コンテナ構成

## 実行方法（ラッパー）
- dbt: `scripts/run_in_container.sh dbt`
- Terraform: `scripts/run_in_container.sh terraform`

## dbt の準備と実行
1. `configs/dbt/profiles.yml.example` を基に `configs/dbt/profiles.yml` を作成する。
2. `scripts/run_in_container.sh dbt` を実行する。

## Terraform の準備と実行
1. `configs/terraform_backend.hcl.example` を基に `configs/terraform_backend.hcl` を作成する。
2. `scripts/run_in_container.sh terraform` を実行する。

## Ingestion の実行
- `scripts/run_ingestion.sh` を実行する。

## 補足
- 実行前チェックは `docs/setup_checklist.md` を参照する。
