---
name: dbt_design
description: dbtのモデル設計、test設計、incremental/snapshot運用の設計判断が必要な場合に使用する。
---

## 設計原則
- staging/core/mart の責務を分離する。
- テストをモデル定義と同時に設計する。
- 再実行可能性と保守性を優先する。

## 実装ルール
- staging: 型変換・命名正規化・最小整形のみ。
- core: 共通ビジネスロジックと再利用可能エンティティ。
- mart: 用途別の最適化済み集計。
- incrementalは `unique_key` と差分条件を明記する。
- snapshotはSCD要件がある場合のみ採用する。
- schema.ymlに主キー・テスト・説明を定義する。

## 命名規約
- モデル: `stg_*`, `core_*`, `mart_*`
- テスト: `not_null_*`, `unique_*`, `relationships_*`
- マクロ: `verb_object` のsnake_case

## 判断基準
- 再利用ロジックはcoreへ集約する。
- full refresh負荷が高い場合はincrementalを優先する。
- 重要指標の整合性テストが不足する場合は実装を保留する。

## 出力フォーマット
1. Summary
2. Design Decisions
- Grain
- Facts and Dimensions
- Layering
- Lineage
- Partition Strategy
- Scalability Considerations
3. Implementation
4. Proposed Improvements
5. Assumptions

## 禁止事項
- test未整備で本番モデルを追加すること
- 粒度不明な集計モデルを作成すること
- 既存ロジックを重複実装すること
