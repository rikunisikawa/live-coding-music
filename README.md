# Fitbit API → 準リアルタイム音楽生成プロジェクト

Fitbit Web API から取得したヘルスケアデータ（心拍・睡眠・活動量）を準リアルタイムで取り込み、音楽生成パイプラインに入力するための設計・骨組みリポジトリです。MVPでは Music Params（JSON）を最終成果物とし、Renderer を差し替えることで MIDI/WAV/OSC へ拡張できる構成を目指します。

## 目的 / MVP範囲
- Fitbit API をポーリングし差分取得（since/until）
- Raw 保存（APIレスポンスをそのまま保持）
- Raw → Normalized → Features → Music Params のパイプライン構築
- MVPの成果物は `music_params.schema.json` に準拠した JSON

詳細なMVP仕様は `docs/requirements.md` を参照してください。

## 開発方針
本プロジェクトの開発方針は「AIエージェントが主体となって自律的に開発・運用できるAIネイティブデータ基盤」です。人間は指示とレビューに集中し、実装・運用はAIエージェントが自律的に行える構造を前提とします。

## AIツール共通運用
本リポジトリは Codex / Claude / Gemini CLI のいずれでも同一の設計・運用ができる「ツール非依存」を前提とする。MCP サーバー設定は `docs/mcp_setup.md` を参照する。

## Skills の共通化方針
Skills はツール非依存の Markdown として扱い、全AIエージェントで同一の知見を参照できるようにする。プロジェクト内の `ai/` と、ローカルの共通 Skills（`~/.codex/skills/`）の両方を参照対象とする。

## AIネイティブ化の工夫
- エージェントが理解しやすいモノレポ構造を採用し、`packages/` 配下で機能を分離。
- `AGENT.md` に運用・実装手順を集約し、AIがこのファイルだけで作業可能にする。
- `packages/ai/prompts/` にAI向けプロンプトテンプレートを配置。
- `scripts/` に実行スクリプトを集約し、`dbt`・`ingestion`・`terraform` を同一導線で操作可能にする。
- `ai/` ディレクトリに設計原則・パターン・テンプレートを配置し、設計意図を明文化。

## 主要ディレクトリ
```
apps/                # 実行アプリ
packages/            # 機能別パッケージ（dbt/ingestion/infra/ai など）
scripts/             # 実行スクリプト
docs/                # 設計・構造・運用ドキュメント
configs/             # config例・schema・mappingルール
fitbit_music/        # 実装パッケージ（CLI/認証/コネクタ/変換/生成）
data/                # Raw/Normalized/Features（gitignore対象）
tests/               # 単体/統合テスト
```

## CLI（設計上の必須コマンド）
- `fitbit-music auth`
- `fitbit-music ingest --since <datetime>`
- `fitbit-music build`
- `fitbit-music run --interval 15m`

## データレイヤ
- Raw: `data/raw/endpoint/date=YYYY-MM-DD/*.json`
- Normalized: `data/normalized/*.parquet`
- Features: `data/features/*.parquet`

詳細は `docs/architecture.md` を参照してください。

## 初期ファイル一覧（雛形）
- `README.md`
- `docs/requirements.md`
- `docs/architecture.md`
- `docs/fitbit_api_endpoints.md`
- `configs/config.example.toml`
- `configs/music_params.schema.json`
- `.env.example`
- `.gitignore`
- `pyproject.toml`

## 開発メモ
- 認証は OAuth2 Authorization Code Flow を想定
- トークンは `.env` か OS keyring に保存（Git管理禁止）
- 収集対象は心拍・睡眠・活動量から開始し、拡張前提

## 次のアクション
- 要件の最終確定（ポーリング間隔・タイムゾーン方針など）
- CLI実装の雛形作成
- コネクタ実装（Heart Rate/Sleep/Activities）

## 実行前提
- dbt: `configs/dbt/profiles.yml.example` を基に `configs/dbt/profiles.yml` を作成する。
- Terraform: `configs/terraform_backend.hcl.example` を基に backend 設定を用意する。
- Docker と Docker Compose が利用可能であること。
- ホストの `~/.aws` に AWS 認証情報が設定されていること。
- `.env` が `.env.example` を基に作成済みであること（`APP_ENV` で環境切替）。

## 実行準備チェック
- `docs/setup_checklist.md` を参照する。

## 開発サイクル（PR作成まで）
- 変更の確定からPR作成までを一括実行する場合は次を使う。
  - `scripts/run_git_cycle.sh -m "コミットメッセージ" -t "PRタイトル"`
- 処理内容は `git add -A` → `git commit` → `git push` → `gh pr create` の順で実行。
- `-b` でベースブランチを指定可能（未指定時は `origin/HEAD` を自動利用）。
- 実行前提として `gh auth login` による GitHub CLI 認証が必要。

## Docker コンテナ運用
- `docs/container_operations.md` を参照する。

## 環境切り替え
- `APP_ENV` の使い方は `docs/env_usage.md` を参照する。
