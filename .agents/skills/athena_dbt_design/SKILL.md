---
name: athena_dbt_design
description: Athena + Glue Data Catalog + dbt + S3 の設計判断が必要なときに使用する。特にテーブル設計、パーティション戦略、incremental実装、クエリコスト最適化を伴う変更で必ず適用する。
---

## 設計原則
- 1モデル1責務を守る。
- レイヤは `staging -> core -> mart` を維持する。
- S3とAthenaはクエリパターンに合わせてパーティション設計する。
- Glue CatalogをSSOTとしてスキーマ整合性を維持する。

## 実装ルール
- `staging` では型変換と命名正規化のみを実施する。
- `core` では再利用可能な事実・ディメンションを構築する。
- `mart` では用途別集計のみを実施する。
- incrementalでは `unique_key` と差分条件を明示する。
- 破壊的DDL変更は影響範囲と移行手順を必ず出力する。

## 命名規約
- dbtモデル: `stg_*`, `core_*`, `mart_*`
- Athenaテーブル: `snake_case`
- パーティション列: `dt`, `event_date`, `event_hour` など意味が明確な名前

## 判断基準
- クエリ頻度が高い指標は `mart` へ昇格する。
- 更新頻度が高いデータは incrementalを優先する。
- スキャン量が増加する設計は却下し、代替案を提示する。
- パーティション粒度は「更新頻度・クエリ条件・データ量」で決定する。

## 出力フォーマット
1. Summary
- 目的と変更範囲

2. Design Decisions
- Grain
- Facts and Dimensions
- Layering
- Lineage
- Partition Strategy
- Scalability Considerations

3. Implementation
- 変更SQL
- テスト観点（dbt test / クエリ検証）

4. Risks
- 影響範囲
- ロールバック方針

## 禁止事項
- `mart` で生データクレンジングを行うこと。
- パーティション設計なしで大規模テーブルを追加すること。
- 冪等性を満たさないappend-only実装を採用すること。
