# データフロー

1. Ingestion がデータを取得し S3/raw に配置する。
2. Glue Catalog でスキーマ管理を行い、Athenaで参照する。
3. dbt が S3/stage から整形し Core/Mart を生成する。
4. 生成データは Athena/Redshift などで参照される。
