# CLAUDE.md

このファイルはClaude Codeがこのリポジトリで作業する際のガイドラインを提供します。

## プロジェクト概要

**live-coding-music** は、Fitbit Charge 6のヘルスケアデータを入力として、リアルタイムに音楽を生成・演奏するライブコーディング音楽システムです。

### 技術スタック

- **データ取得**: Fitbit Web API (OAuth 2.0 + PKCE) → AWS Lambda
- **データ基盤**: S3 (Apache Iceberg) + Glue Data Catalog + Athena
- **データモデリング**: dbt (staging → intermediate → marts)
- **音楽生成**: Python → FoxDot → OSC → SuperCollider
- **IaC**: Terraform
- **実行環境**: AWS (データ基盤) + Windows ローカルPC (音楽生成)

## プロジェクト構成

```
live-coding-music/
├── CLAUDE.md                # Claude Code向けガイドライン（本ファイル）
├── docs/
│   └── requirements.md      # 要件定義書
├── terraform/               # AWSインフラ定義
├── lambda/                  # Lambda関数（データ取得）
├── dbt_project/             # dbtモデル
├── music/                   # 音楽生成スクリプト（Python + FoxDot）
└── scripts/                 # ユーティリティスクリプト
```

## 開発ガイドライン

### 基本方針

- コードはシンプルで読みやすく保つ
- コミットメッセージは変更内容を明確に記述する
- 新機能の追加時は既存コードとの整合性を確認する

### コーディング規約

- **Python**: インデントはスペース4つ。PEP 8に準拠
- **SQL (dbt)**: インデントはスペース2つ。小文字キーワード
- **Terraform (HCL)**: インデントはスペース2つ。`terraform fmt`で整形
- 変数名・関数名は意味のある名前を付ける
- 必要に応じてコメントを記述する（日本語可）

## ビルド・実行コマンド

```bash
# Terraform
cd terraform/environments/prod
terraform init
terraform plan
terraform apply

# dbt
cd dbt_project
dbt run
dbt test

# 音楽生成（Windowsローカル）
python music/music_controller.py
```

## テスト

```bash
# dbt テスト
cd dbt_project
dbt test

# Python テスト
pytest lambda/tests/
pytest music/tests/
```

## 注意事項

- 機密情報（APIキー、パスワード、Fitbitトークン等）はリポジトリにコミットしない
- `.env` ファイルはバージョン管理に含めない
- Fitbit OAuthトークンはAWS Secrets Managerで管理する
- 詳細な要件は `docs/requirements.md` を参照
