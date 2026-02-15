# 環境変数（APP_ENV）運用ガイド

本リポジトリでは `APP_ENV` を共通スイッチとして使用し、dbt と Terraform の対象環境を同時に切り替える。

## 使い方
1. `.env.example` を基に `.env` を作成する。
2. `.env` の `APP_ENV` を `dev` または `prod` に設定する。

## 影響範囲
- dbt: `configs/dbt/profiles.yml` の `target` が `APP_ENV` を参照する。
- Terraform: `scripts/run_in_container.sh terraform-plan` が `APP_ENV` に応じて以下を切り替える。
  - `packages/infra/env/${APP_ENV}.tfvars`
  - `configs/terraform_backend.${APP_ENV}.hcl`

## Athena/Glue の用語対応
- Catalog: `ATHENA_CATALOG`（例: `AwsDataCatalog`）
- Database: `ATHENA_SCHEMA_DEV/PROD`（例: `<project>_staging`）

## 例
```
APP_ENV=dev
```

```
APP_ENV=prod
```

## 注意点
- `APP_ENV` を未設定のまま実行するとエラーになる。
- `prod` での実行は破壊的変更の可能性があるため、必ず人間の承認を得る。
