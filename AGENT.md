# AI エージェント運用ガイド

## リポジトリ構造
- apps/: 実行アプリ
- packages/: 機能別パッケージ
  - dbt/: dbtモデル
  - ingestion/: 取り込みパイプライン
  - infra/: Terraform構成
  - ai/: AI用プロンプト
- scripts/: 実行スクリプト
- docs/: 解説
- configs/: 設定

## ツール非依存の前提
本リポジトリは Codex / Claude / Gemini CLI で同一の運用ができることを前提とする。MCP サーバーの導入と利用ルールは `docs/mcp_setup.md` を参照する。

## Skills の参照先
- リポジトリ内: `ai/skills/`
- ローカル共通: `~/.codex/skills/`
どちらもツール非依存の Markdown として扱う。

## dbt の実行方法
1. `scripts/run_in_container.sh dbt` を実行する。
2. `packages/dbt/` 配下のモデルに対して `dbt run` と `dbt test` が行われる。

## 実行前提（dbt）
- `configs/dbt/profiles.yml.example` を基に `configs/dbt/profiles.yml` を作成する。
- Docker と Docker Compose が利用可能であること。
- ホストの `~/.aws` に AWS 認証情報が設定されていること。
- `.env` が `.env.example` を基に作成済みであること（`APP_ENV` で環境切替）。

## Terraform の操作方法
1. `scripts/run_in_container.sh terraform-plan` を実行する。
2. `packages/infra` で `terraform init` と `plan` が行われる。

## 実行前提（Terraform）
- `configs/terraform_backend.hcl.example` を基に backend 設定を用意する。
- Docker と Docker Compose が利用可能であること。
- ホストの `~/.aws` に AWS 認証情報が設定されていること。
- `APP_ENV` に応じて `packages/infra/env/${APP_ENV}.tfvars` が読み込まれる。

## Ingestion の作成方法
1. `packages/ingestion/src/base_ingestion.py` を継承して新規クラスを作成。
2. `packages/ingestion/examples/` に実行例を追加。
3. `scripts/run_ingestion.sh` で動作確認。

## AI が安全に変更するためのルール
- 変更前に影響範囲を明記する。
- 既存のGrainとLineageを壊さない。
- dbt/infra の変更はスクリプト経由で検証する。
- 破壊的変更は必ず人間に承認を求める。

## 実行準備チェックリスト
- `docs/setup_checklist.md` を参照して全項目を満たすこと。

## Docker コンテナ運用
- `docs/container_operations.md` を参照する。

## 環境切り替え
- `APP_ENV` の使い方は `docs/env_usage.md` を参照する。
