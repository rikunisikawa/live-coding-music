# Fitbitデータ取得実装（MVP）

## 0. Spec ID
- spec_id: `20260215_fitbit_data_ingestion`

## 1. 背景
- 現在リポジトリには Fitbit API 取り込みの本体実装がなく、`BaseIngestion` の雛形のみが存在する。
- MVP要件では Heart Rate / Sleep / Activities(steps) を Fitbit API から取得し、Raw(JSON)保存することが必須である。

## 2. 目的
- Fitbit API から指定期間のデータを取得し、Rawレイヤに保存できるCLI (`fitbit-music ingest`) を実装する。

## 3. スコープ
- OAuthアクセストークンを利用した Fitbit API 呼び出し。
- 取得対象: heart_rate / sleep / steps。
- `--since` `--until` で指定した日付範囲の取得。
- Raw(JSON)を `data/raw/<endpoint>/date=YYYY-MM-DD/*.json` 形式で保存。

## 4. 非スコープ
- OAuth認可コード取得フロー (`fitbit-music auth`) の実装。
- Normalized/Features/Music Params の実装。
- Webhook受信や準リアルタイム常駐実行。

## 5. 要件
### 5.1 機能要件
- `fitbit-music ingest --since <ISO8601> --until <ISO8601>` で実行できること。
- 指定期間の日付ごとに Fitbit API を呼び出せること。
- APIレスポンスを endpoint/date 単位で Raw保存できること。
- 失敗時に対象 endpoint/date を含むエラーメッセージを返すこと。

### 5.2 非機能要件
- 冪等性: 同一日付を再取得しても上書きではなく新規ファイルとして保存し、履歴を保持する。
- セキュリティ: トークンをログ出力しない。
- 可観測性: 取得件数と保存先を標準出力で確認できる。

## 6. 設計方針
### 6.1 Grain
- Rawレコード粒度: 「1 endpoint × 1 date × 1 APIレスポンス」。
- 保存ファイル粒度: 「1 endpoint × 1 date × 1 取得実行」。

### 6.2 Facts and Dimensions
- Fact: Fitbit APIレスポンス本文（時系列値や睡眠ログ）。
- Dimension: endpoint名、対象日付、取得時刻、source(Fitbit API) などのメタデータ。

### 6.3 Layering (Raw/Core/Mart)
- Raw: 本Specで実装（APIレスポンスJSON保存）。
- Core/Mart: 本Specでは対象外（後続Specで実装）。

### 6.4 Lineage
- Fitbit Web API
  -> `fitbit_music.fitbit_api.FitbitApiClient`
  -> `fitbit_music.ingestion.FitbitRawIngestionService`
  -> `fitbit_music.raw_storage.RawStorage`
  -> `data/raw/<endpoint>/date=YYYY-MM-DD/*.json`

### 6.5 Partition Strategy
- 日付（`date=YYYY-MM-DD`）でパーティション相当のディレクトリ分割を行う。
- endpoint単位でディレクトリを分離し、後続の正規化処理でスキャン範囲を限定できる構造にする。

### 6.6 Scalability Considerations
- 期間を日単位ループで処理し、1リクエスト失敗時の切り分けを容易にする。
- endpoint/date単位の保存により再処理時の対象絞り込みを可能にする。
- 将来S3移行しやすいようにRaw保存責務を `RawStorage` に分離する。

## 7. 受け入れ条件（Acceptance Criteria）
- [x] `fitbit-music ingest --since --until` が実行できる。
- [ ] heart_rate / sleep / steps を日付範囲で取得し Raw保存できる。
- [x] 保存パスが `data/raw/<endpoint>/date=YYYY-MM-DD/*.json` 形式である。
- [ ] 取得対象・保存件数のサマリーがCLI出力される。
- [x] 単体テストが追加され、ローカルで成功する。

## 8. 実装タスク
1. CLIエントリポイントと `ingest` サブコマンドを追加する。
2. Fitbit APIクライアントを実装し、対象endpointを日付単位で取得する。
3. Raw保存クラスを実装し、所定ディレクトリ構造でJSONを保存する。
4. Ingestionサービスで取得から保存までを接続する。
5. URL生成・保存パスに関する単体テストを追加する。

## 9. テスト計画
- 単体テスト:
  - endpoint URL解決が期待通りであること。
  - Raw保存パスとJSON内容が期待通りであること。
- 結合テスト:
  - 実トークン環境で `fitbit-music ingest --since ... --until ...` を実行し、Raw保存を確認する。
- 手動確認:
  - `data/raw/heart_rate/date=...` 等にJSONが作成されることを確認する。

### 9.1 検証結果（2026-02-15）
- 成功: `python -m unittest discover -s tests -p 'test_*.py'`（2件成功）
- 成功: `python -m fitbit_music.cli --help`
- 未実施: 実APIを使った `fitbit-music ingest --since ... --until ...`（実トークン・ネットワーク疎通が必要）

## 10. リスクと対策
- リスク: アクセストークン期限切れで取得失敗する。
- 対策: エラーにHTTP statusとendpoint/dateを含め、運用時に迅速に再認証できるようにする。
- リスク: Fitbit APIレート制限に達する。
- 対策: 日付単位の最小呼び出しに限定し、将来のリトライ制御追加余地を残す。

## 11. 未確定事項
- activities は steps 以外（calories, distanceなど）をMVP範囲に含めるか。
- トークン更新（refresh token）を本CLI内で自動実施するか。

## 12. 変更履歴
- 2026-02-15: 初版作成
