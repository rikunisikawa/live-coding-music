# dbt パッケージ

このディレクトリは dbt Core のプロジェクトを配置する。
- `models/`: モデル定義
- `seeds/`: マスターデータ
- `tests/`: カスタムテスト

AI は `scripts/run_dbt.sh` から操作すること。

## profiles.yml の利用
- `configs/dbt/profiles.yml.example` を基に `configs/dbt/profiles.yml` を作成する。
- `scripts/run_dbt.sh` が `DBT_PROFILES_DIR=configs/dbt` を使用する。
- 実行環境（Athena/Glue/S3）へのアクセス権が必要。
