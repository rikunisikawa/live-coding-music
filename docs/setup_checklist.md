# 実行準備チェックリスト

AI自立開発の実行準備が完了しているかを確認するためのチェックリストです。

## 1. Docker 前提
- [ ] Docker が利用可能
- [ ] Docker Compose が利用可能

## 2. AWS 認証情報
- [ ] AWS CLI/SDK の認証情報が設定済み（例: `aws sts get-caller-identity` が成功）
- [ ] Athena / Glue / S3 / DynamoDB への必要権限が付与されている
- [ ] ホストの `~/.aws` に認証情報が配置済み

## 3. Terraform Backend
- [ ] S3 バケット（Terraform state 用）が作成済み
- [ ] DynamoDB ロックテーブルが作成済み
- [ ] `configs/terraform_backend.hcl` に実値が設定済み

## 4. dbt 実行設定
- [ ] `configs/dbt/profiles.yml` が `configs/dbt/profiles.yml.example` を基に作成済み
- [ ] Athena の `s3_staging_dir` が実在バケットに設定済み
- [ ] Glue Catalog / database / schema が利用可能

## 5. データソース
- [ ] Fitbit API の認証情報・トークン取得方法が確定
- [ ] Raw データの保存先（ローカル or S3）が確定

## 6. 最小動作確認
- [ ] `scripts/run_ingestion.sh` が成功する
- [ ] `scripts/run_in_container.sh terraform` が plan を生成できる
- [ ] `scripts/run_in_container.sh dbt` が dbt run/test まで実行できる
