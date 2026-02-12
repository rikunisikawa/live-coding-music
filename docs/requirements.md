# 要件定義書：live-coding-music

## 1. プロジェクト概要

Fitbit Charge 6のヘルスケアデータを入力として、リアルタイムに音楽を生成・演奏するライブコーディング音楽システム。

### システム全体像

```
Fitbit Charge 6
    │ BLE (15〜30分間隔で同期)
    ▼
Fitbitスマホアプリ
    │ HTTPS
    ▼
Fitbit Cloud
    │
    ├── Webhook通知 ──→ API Gateway → Lambda (イベント駆動取得)
    │                                    │
    ├── 定期ポーリング → EventBridge Scheduler → Lambda (スケジュール取得)
    │                                    │
    ▼                                    ▼
                    Fitbit Web API からデータ取得
                              │
                              ▼
                    S3 (Raw Layer / Iceberg)
                              │
                              ▼
                    dbt (データモデリング)
                              │
                              ▼
                    S3 (Mart Layer / Iceberg)
                              │
                              ▼
                    Athena (クエリエンジン)
                              │
                              ▼
                    Python (データ取得・音楽パラメータ変換)
                              │
                              ▼
                    FoxDot (ライブコーディングライブラリ)
                              │ OSC
                              ▼
                    SuperCollider (音声合成エンジン)
                              │
                              ▼
                    オーディオ出力 (スピーカー)
```

## 2. 前提条件

| 項目 | 内容 |
|-----|------|
| デバイス | Fitbit Charge 6 |
| ユーザー数 | 1人（自分のみ） |
| Fitbit App種別 | Personal（自分のデータのみアクセス） |
| データ取得方式 | 準リアルタイム（Webhook + 定期ポーリング） |
| クラウド基盤 | AWS |
| DWH / クエリエンジン | Amazon Athena |
| テーブルフォーマット | Apache Iceberg |
| IaC | Terraform |
| データ保持期間 | 永続（削除しない） |
| 音楽更新間隔 | 1分に1回 |
| 音楽生成環境 | Windows ローカルPC |
| 音楽生成スタック | Python → FoxDot → OSC → SuperCollider → スピーカー |

## 3. データソース定義

### 3.1 Fitbit Web API 認証

| 項目 | 内容 |
|-----|------|
| 認証方式 | OAuth 2.0 Authorization Code + PKCE |
| アクセストークン有効期限 | 8時間 |
| リフレッシュトークン | 無期限（使い捨て、使用時に新トークン発行） |
| レート制限 | 150リクエスト/ユーザー/時間 |
| 必要スコープ | activity, heartrate, sleep, oxygen_saturation, respiratory_rate, temperature, electrocardiogram, cardio_fitness, weight, nutrition, profile, settings |

### 3.2 取得対象データ一覧

#### リアルタイム系（デバイス同期のたびに更新）

| # | データ種別 | APIエンドポイント | 取得粒度 | 取得方式 |
|---|-----------|-----------------|---------|---------|
| 1 | 心拍数 | `/1/user/-/activities/heart/date/{date}/1d/1sec.json` | 1秒(運動中) / 5秒(安静時) | Webhook(`activities`) + ポーリング |
| 2 | 歩数 | `/1/user/-/activities/steps/date/{date}/1d/1min.json` | 1分間隔 | Webhook(`activities`) + ポーリング |
| 3 | 消費カロリー | `/1/user/-/activities/calories/date/{date}/1d/1min.json` | 1分間隔 | Webhook(`activities`) + ポーリング |
| 4 | 距離 | `/1/user/-/activities/distance/date/{date}/1d/1min.json` | 1分間隔 | Webhook(`activities`) + ポーリング |
| 5 | 階段数 | `/1/user/-/activities/floors/date/{date}/1d/1min.json` | 1分間隔 | Webhook(`activities`) + ポーリング |
| 6 | アクティビティ分類 | `/1/user/-/activities/date/{date}.json` | 日次サマリ + 個別ログ | Webhook(`activities`) + ポーリング |
| 7 | アクティブゾーン分 | `/1/user/-/activities/active-zone-minutes/date/{date}/1d.json` | 日次 | Webhook(`activities`) + ポーリング |

#### 睡眠系（1日1回、睡眠終了後に更新）

| # | データ種別 | APIエンドポイント | 取得粒度 | 取得方式 |
|---|-----------|-----------------|---------|---------|
| 8 | 睡眠ステージ | `/1.2/user/-/sleep/date/{date}.json` | 30秒間隔のステージデータ | Webhook(`sleep`) + ポーリング |
| 9 | HRV（心拍変動） | `/1/user/-/hrv/date/{date}/all.json` | 睡眠中5分間隔 | ポーリングのみ |
| 10 | SpO2（血中酸素） | `/1/user/-/spo2/date/{date}/all.json` | 睡眠中の測定値 | ポーリングのみ |
| 11 | 呼吸数 | `/1/user/-/br/date/{date}/all.json` | 睡眠セッション単位 | ポーリングのみ |
| 12 | 皮膚温度 | `/1/user/-/temp/skin/date/{date}.json` | 睡眠セッション単位 | ポーリングのみ |

#### オンデマンド系（手動測定・入力時に更新）

| # | データ種別 | APIエンドポイント | 取得粒度 | 取得方式 |
|---|-----------|-----------------|---------|---------|
| 13 | ECG（心電図） | `/1/user/-/ecg/list.json` | 測定ごと（波形データ） | ポーリングのみ |
| 14 | VO2 Max | `/1/user/-/cardioscore/date/{date}.json` | 日次 | ポーリングのみ |
| 15 | 体重 | `/1/user/-/body/log/weight/date/{date}.json` | 手動入力 | Webhook(`body`) + ポーリング |
| 16 | 体脂肪率 | `/1/user/-/body/log/fat/date/{date}.json` | 手動入力 | Webhook(`body`) + ポーリング |
| 17 | 食事ログ | `/1/user/-/foods/log/date/{date}.json` | 手動入力 | Webhook(`foods`) + ポーリング |
| 18 | 水分摂取 | `/1/user/-/foods/log/water/date/{date}.json` | 手動入力 | Webhook(`foods`) + ポーリング |

#### デバイス・プロフィール

| # | データ種別 | APIエンドポイント | 取得粒度 | 取得方式 |
|---|-----------|-----------------|---------|---------|
| 19 | ユーザープロフィール | `/1/user/-/profile.json` | - | 初回 + 変更時 |
| 20 | デバイス情報 | `/1/user/-/devices.json` | - | 日次ポーリング |

### 3.3 レート制限内でのポーリング戦略

150リクエスト/時間の制約下での取得スケジュール。

```
■ 高頻度（5分間隔 = 12回/時間）
  - 心拍数 Intraday     : 12リクエスト
  - 歩数 Intraday       : 12リクエスト
  - カロリー Intraday    : 12リクエスト
                          小計: 36リクエスト/時間

■ 中頻度（15分間隔 = 4回/時間）
  - 距離 Intraday       : 4リクエスト
  - 階段 Intraday       : 4リクエスト
  - アクティビティサマリ  : 4リクエスト
  - AZM                 : 4リクエスト
                          小計: 16リクエスト/時間

■ 低頻度（1時間に1回）
  - 睡眠                : 1リクエスト
  - HRV                 : 1リクエスト
  - SpO2                : 1リクエスト
  - 呼吸数              : 1リクエスト
  - 皮膚温度            : 1リクエスト
  - ECG                 : 1リクエスト
  - VO2 Max             : 1リクエスト
  - 体重                : 1リクエスト
  - 栄養                : 1リクエスト
  - 水分                : 1リクエスト
                          小計: 10リクエスト/時間

■ 極低頻度（日次）
  - プロフィール          : 1リクエスト/日
  - デバイス情報          : 1リクエスト/日
                          小計: ≒ 0リクエスト/時間

────────────────────────────────
合計: 約62リクエスト/時間（上限150に対して余裕あり）
```

## 4. AWSアーキテクチャ

### 4.1 サービス構成

| レイヤー | サービス | 用途 |
|---------|---------|------|
| API受信 | API Gateway (REST) | Fitbit Webhookの受信エンドポイント |
| コンピュート | Lambda (Python) | データ取得・S3書き込み |
| スケジューラ | EventBridge Scheduler | 定期ポーリングのトリガー |
| ストレージ | S3 | データレイク（Icebergテーブル） |
| カタログ | Glue Data Catalog | Icebergテーブルメタデータ管理 |
| クエリ | Athena v3 | SQLクエリ・dbt実行エンジン |
| シークレット管理 | Secrets Manager | Fitbit OAuth トークン保管 |
| 認証基盤 | Cognito or Lambda | OAuth 2.0フローのハンドリング |
| モニタリング | CloudWatch | ログ・メトリクス・アラーム |
| IaC | Terraform | インフラ全体の構成管理 |

### 4.2 S3バケット構成

```
s3://live-coding-music-data-{account_id}/
├── raw/                          # Fitbit APIレスポンスそのまま
│   ├── heart_rate/
│   │   ├── year=2026/
│   │   │   └── month=02/
│   │   │       └── day=12/
│   │   │           └── {timestamp}.json
│   │   └── ...
│   ├── steps/
│   ├── calories/
│   ├── sleep/
│   ├── hrv/
│   ├── spo2/
│   ├── breathing_rate/
│   ├── skin_temperature/
│   ├── ecg/
│   ├── vo2_max/
│   ├── active_zone_minutes/
│   ├── distance/
│   ├── floors/
│   ├── activity_summary/
│   ├── weight/
│   ├── body_fat/
│   ├── food_log/
│   ├── water_log/
│   ├── profile/
│   └── devices/
│
├── iceberg/                      # Icebergテーブルデータ
│   ├── staging/                  # dbt staging models
│   ├── intermediate/             # dbt intermediate models
│   └── marts/                    # dbt mart models
│
└── athena-results/               # Athenaクエリ結果
```

### 4.3 Apache Iceberg テーブル設計方針

**Apache Icebergを採用する理由：**
- Athena v3でネイティブサポート
- ACID トランザクション（小規模な頻繁書き込みに適合）
- スキーマ進化（APIレスポンス変更への対応）
- タイムトラベル（過去のスナップショットへのクエリ）
- パーティション進化（後からパーティション構造を変更可能）
- Parquet形式による高い圧縮率・クエリ性能

**テーブル共通設定：**
- ファイルフォーマット: Parquet
- 圧縮: Zstandard (zstd)
- パーティション: 日付ベース（日単位）
- ソートキー: タイムスタンプ

## 5. dbt モデリング

### 5.1 レイヤー構成

```
dbt_project/
├── models/
│   ├── staging/                  # APIレスポンスの正規化・型変換
│   │   ├── stg_heart_rate.sql
│   │   ├── stg_steps.sql
│   │   ├── stg_calories.sql
│   │   ├── stg_sleep.sql
│   │   ├── stg_hrv.sql
│   │   ├── stg_spo2.sql
│   │   ├── stg_breathing_rate.sql
│   │   ├── stg_skin_temperature.sql
│   │   ├── stg_ecg.sql
│   │   ├── stg_vo2_max.sql
│   │   ├── stg_active_zone_minutes.sql
│   │   ├── stg_distance.sql
│   │   ├── stg_floors.sql
│   │   ├── stg_activity_summary.sql
│   │   ├── stg_weight.sql
│   │   ├── stg_body_fat.sql
│   │   ├── stg_food_log.sql
│   │   ├── stg_water_log.sql
│   │   └── stg_profile.sql
│   │
│   ├── intermediate/             # データの結合・集計・エンリッチメント
│   │   ├── int_vital_signs.sql         # 心拍+HRV+SpO2+呼吸数の統合
│   │   ├── int_sleep_quality.sql       # 睡眠ステージ+スコア+関連バイタル
│   │   ├── int_activity_metrics.sql    # 歩数+カロリー+距離+階段+AZM
│   │   ├── int_body_composition.sql    # 体重+体脂肪+VO2Max
│   │   └── int_nutrition.sql           # 食事+水分
│   │
│   └── marts/                    # 音楽生成向け最終モデル
│       ├── mart_realtime_music_params.sql   # 1分更新用：最新バイタル→音楽パラメータ
│       ├── mart_daily_health_summary.sql    # 日次ヘルスサマリ
│       └── mart_sleep_music_params.sql      # 睡眠データ→音楽パラメータ
│
├── macros/
├── tests/
├── seeds/
└── dbt_project.yml
```

### 5.2 主要マートモデル

#### mart_realtime_music_params

音楽生成エンジンが1分ごとに参照するメインテーブル。

| カラム | 型 | 説明 | 音楽マッピング例 |
|-------|-----|------|----------------|
| measured_at | timestamp | 測定タイムスタンプ | - |
| heart_rate_bpm | int | 現在心拍数 | テンポ (BPM) |
| heart_rate_zone | string | 心拍ゾーン(rest/fat_burn/cardio/peak) | 楽器セット切替 |
| steps_per_min | int | 直近1分間の歩数 | リズムパターン |
| calories_per_min | float | 直近1分間の消費カロリー | 音量・エネルギー |
| active_minutes_today | int | 当日のアクティブ分 | 曲の複雑さ |
| current_activity | string | 現在のアクティビティ種別 | ジャンル切替 |
| last_sleep_score | int | 直近の睡眠スコア | 調性(明るさ/暗さ) |
| last_hrv_rmssd | float | 直近のHRV(RMSSD) | 和声の緊張感 |
| last_spo2_avg | float | 直近のSpO2平均値 | 音の広がり |
| last_skin_temp_delta | float | 皮膚温度変動 | エフェクト |
| last_breathing_rate | float | 直近の呼吸数 | 音のリリース長 |
| data_freshness_sec | int | データの鮮度（秒） | - |

## 6. 音楽生成パイプライン（Windowsローカル）

### 6.1 コンポーネント構成

```
[Windows PC]
│
├── Python スクリプト (music_controller.py)
│   ├── 1分間隔で Athena にクエリ (boto3)
│   ├── ヘルスケアデータ → 音楽パラメータ変換
│   └── FoxDot API で音楽パラメータを更新
│
├── FoxDot (Python ライブコーディングライブラリ)
│   └── OSC メッセージ送信
│
└── SuperCollider (音声合成エンジン)
    └── オーディオ出力 → スピーカー
```

### 6.2 必要ソフトウェア

| ソフトウェア | バージョン | 用途 |
|------------|----------|------|
| Python | 3.10+ | 制御スクリプト |
| FoxDot | 0.8+ | ライブコーディングライブラリ |
| SuperCollider | 3.13+ | 音声合成エンジン |
| boto3 | latest | AWS SDK for Python |
| AWS CLI | v2 | AWS認証・設定 |

### 6.3 音楽パラメータマッピング方針

```python
# 例: 心拍数 → テンポ
# 安静時心拍(60) → BPM 80
# 通常心拍(80)   → BPM 120
# 運動時心拍(140) → BPM 160
tempo = map_range(heart_rate, 50, 180, 60, 180)

# 例: 睡眠スコア → 調性
# 高スコア(80-100) → メジャーキー（明るい）
# 低スコア(0-50)   → マイナーキー（暗い）

# 例: HRV → 和声の複雑さ
# 高HRV（リラックス） → シンプルな和声
# 低HRV（ストレス）   → テンション多め
```

## 7. Terraform モジュール構成

```
terraform/
├── main.tf
├── variables.tf
├── outputs.tf
├── providers.tf
├── backend.tf                    # S3 + DynamoDB state管理
│
├── modules/
│   ├── s3/                       # S3バケット（データレイク + Athena結果）
│   ├── glue/                     # Glue Data Catalog（Icebergカタログ）
│   ├── athena/                   # Athena ワークグループ
│   ├── lambda/                   # Lambda関数（データ取得）
│   │   ├── fitbit_webhook_handler/
│   │   ├── fitbit_poller/
│   │   └── fitbit_token_refresher/
│   ├── api_gateway/              # Webhook受信用API Gateway
│   ├── eventbridge/              # スケジュールルール
│   ├── secrets_manager/          # Fitbitトークン管理
│   ├── iam/                      # IAMロール・ポリシー
│   └── cloudwatch/               # モニタリング・アラーム
│
└── environments/
    └── prod/
        ├── main.tf
        ├── terraform.tfvars
        └── backend.tf
```

## 8. 処理フロー詳細

### 8.1 準リアルタイムデータ取得フロー

```
1. Fitbit Charge 6 がスマホとBLE同期（15〜30分間隔）
2. Fitbit Cloud にデータアップロード
3a. [Webhook経路]
    - Fitbit → API Gateway → Lambda (webhook_handler)
    - Lambda がWebhook通知を解析
    - 該当データ種別のFitbit APIを呼び出し
    - JSONレスポンスをS3 raw/に書き込み

3b. [ポーリング経路]
    - EventBridge Scheduler → Lambda (poller) を5分間隔で実行
    - Lambda が各エンドポイントを呼び出し
    - JSONレスポンスをS3 raw/に書き込み

4. dbt run（EventBridge Schedulerで5分間隔 or データ到着時）
   - staging: raw JSONからIcebergテーブルへ正規化
   - intermediate: データ結合・集計
   - marts: 音楽パラメータ用テーブルを更新

5. Windows PC上のPythonスクリプト（1分間隔ループ）
   - Athenaでmart_realtime_music_paramsをクエリ
   - 音楽パラメータに変換
   - FoxDotのパラメータをリアルタイム更新
   - SuperCollider経由で音声出力
```

### 8.2 OAuth トークン管理フロー

```
1. 初回: ローカルPCでOAuth認証フローを実行
2. アクセストークン + リフレッシュトークンをSecrets Managerに保存
3. Lambda実行時にSecrets Managerからトークン取得
4. アクセストークン期限切れ時（8時間）→ Lambda内で自動リフレッシュ
5. 新しいトークンをSecrets Managerに上書き保存
```

## 9. 非機能要件

| 項目 | 要件 |
|-----|------|
| データ鮮度 | Fitbit同期後5分以内にmartsテーブルに反映 |
| 音楽更新頻度 | 1分に1回 |
| 可用性 | 個人利用のため高可用性は不要。障害時は手動復旧 |
| データ保持 | 永続（削除ポリシーなし） |
| コスト最適化 | サーバーレス構成で使った分だけ課金。月額想定: $5〜15 |
| セキュリティ | Fitbitトークンは暗号化保存。S3はデフォルト暗号化有効 |
| モニタリング | CloudWatchでLambdaエラー・APIレート制限超過をアラート |

## 10. 開発フェーズ

| フェーズ | 内容 | 成果物 |
|---------|------|--------|
| Phase 1 | Terraform基盤構築 + Fitbit OAuth認証 | AWS環境・認証フロー |
| Phase 2 | Lambda（データ取得）+ S3書き込み | Rawデータの継続的取得 |
| Phase 3 | dbtモデリング + Icebergテーブル | staging/intermediate/martsモデル |
| Phase 4 | Windowsローカル音楽生成スクリプト | Python + FoxDot + SuperCollider |
| Phase 5 | 統合テスト・チューニング | エンドツーエンド動作確認 |
