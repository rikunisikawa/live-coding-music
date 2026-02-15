# Terraform 構成

`modules/` に再利用可能なモジュール、`env/` に環境別の変数ファイルを配置する。
AI は `scripts/run_in_container.sh terraform-plan` から操作すること。

## 環境切り替え
- `.env` の `APP_ENV` を `dev` / `prod` に切り替える。
- `packages/infra/env/${APP_ENV}.tfvars` が読み込まれる。
