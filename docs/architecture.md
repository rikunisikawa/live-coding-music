# アーキテクチャ概要

本リポジトリはAIエージェント主体で開発・運用するためのモノレポ構成である。Codex / Claude / Gemini CLI のいずれでも同一の運用ができるツール非依存を前提とする。

- apps/: 実行アプリケーション群
- packages/: 主要機能ごとのパッケージ
  - db/: データアクセス層
  - dbt/: dbtモデル
  - ingestion/: 取り込みパイプライン
  - api/: API層
  - infra/: Terraform構成
  - ai/: AI用プロンプトと支援
- scripts/: AIが実行するスクリプト
- docs/: 構造理解用ドキュメント
- configs/: 環境設定
