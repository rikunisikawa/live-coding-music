# dbt 構造

- packages/dbt/models/staging: 生データの正規化
- packages/dbt/models/core: 共有可能なエンティティ
- packages/dbt/models/mart: 目的別集計

実行は `scripts/run_dbt.sh` を使用する。
