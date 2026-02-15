---
name: dbt_modeling
description: dbtモデルの新規作成・変更・レビュー時に使用する。materialization、test、snapshot、incremental運用の判断が必要な場合に適用する。
---

## 設計原則
- dbtは宣言的に設計し、再実行可能性を最優先する。
- モデル粒度を明示し、集計責務を分離する。
- testをモデル定義と同時に設計する。

## 実装ルール
- すべての主要モデルに `not_null` / `unique` / `relationships` を検討する。
- incrementalは `unique_key` と遅延到着データ方針を定義する。
- snapshotはSCD要件がある場合のみ採用する。
- schema.ymlにモデル説明、主キー、品質ルールを記載する。

## 命名規約
- モデル名: `stg_`, `core_`, `mart_` プレフィックス
- テスト名: 意味が分かる列名中心（例: `not_null_core_events_event_id`）
- マクロ名: `verb_object` のsnake_case

## 判断基準
- 再利用されるロジックは `core` へ。
- 利用者依存の集計は `mart` へ。
- full refreshが高コストな場合は incremental優先。
- モデル変更時は既存ダッシュボード影響を優先確認する。

## 出力フォーマット
1. Summary
- 対象モデルと変更意図

2. Design Decisions
- Grain
- Facts and Dimensions
- Layering
- Lineage
- Partition Strategy
- Scalability Considerations

3. Implementation
- SQL / schema.yml 差分
- dbt run / dbt test 手順

4. Assumptions
- 前提と未確定事項

## 禁止事項
- テスト未定義のまま本番向けモデルを追加すること。
- 粒度が不明な集計モデルを作成すること。
- 既存 `core` ロジックを重複実装すること。
