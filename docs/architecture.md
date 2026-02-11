# アーキテクチャ概要

## パイプライン
```
Fitbit API → Raw → Normalized → Features → Music Params → Renderer
```

## データレイヤ設計
### Raw
- 目的: APIレスポンスを加工せず保存し、再処理の基盤とする。
- 保存先: `data/raw/<endpoint>/date=YYYY-MM-DD/*.json`

### Normalized
- 目的: エンドポイント固有の構造を統一し、時系列イベントとして表現。
- 保存先: `data/normalized/*.parquet`
- 方針:
  - UTC正規化
  - 欠損補完方針をドキュメント化

### Features
- 目的: 音楽生成に使う特徴量を抽出。
- 保存先: `data/features/*.parquet`
- 例:
  - 平均/分散HR
  - HRV系指標
  - 睡眠段階の比率
  - 活動量（歩数/活動時間）

## Music Params
- `configs/music_params.schema.json` をスキーマとして定義。
- BPMやテンポ変化、強弱などの制御パラメータを想定。

## モジュール設計
### Connector
- Fitbit APIの各エンドポイントに対応する取得モジュール。
- `fitbit_music/connectors/` に配置。

### Renderer
- Music Paramsを受け取り、MIDI/WAV/OSC等へ変換。
- `fitbit_music/generate/` に配置。

## 実行方式
- CLI 実行（WSL環境）を前提。
- スケジュールは cron / systemd timer を想定。
