# Fitbit API → 準リアルタイム音楽生成プロジェクト

Fitbit Web API から取得したヘルスケアデータ（心拍・睡眠・活動量）を準リアルタイムで取り込み、音楽生成パイプラインに入力するための設計・骨組みリポジトリです。MVPでは Music Params（JSON）を最終成果物とし、Renderer を差し替えることで MIDI/WAV/OSC へ拡張できる構成を目指します。

## 目的 / MVP範囲
- Fitbit API をポーリングし差分取得（since/until）
- Raw 保存（APIレスポンスをそのまま保持）
- Raw → Normalized → Features → Music Params のパイプライン構築
- MVPの成果物は `music_params.schema.json` に準拠した JSON

詳細なMVP仕様は `docs/requirements.md` を参照してください。

## 主要ディレクトリ
```
fitbit_music/        # 実装パッケージ（CLI/認証/コネクタ/変換/生成）
configs/             # config例・schema・mappingルール
 data/               # Raw/Normalized/Features（gitignore対象）
 docs/               # 要件・設計・API調査
 tests/              # 単体/統合テスト
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

