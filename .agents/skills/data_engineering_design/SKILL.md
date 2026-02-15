---
name: data_engineering_design
description: データエンジニアリング設計（Grain/Fact/Dimension/Lineage/Idempotency/Partition）を定義・レビューするときに使用する。
---

## 設計原則
- 粒度（Grain）を先に固定する。
- FactとDimensionを分離する。
- Coreを先に定義し、Martは用途別に派生する。

## 実装ルール
- すべての主要データセットでGrainを明記する。
- 依存関係をLineageとして明示する。
- 差分処理は安定キーと冪等性を必須にする。
- Partitionはクエリ条件とデータ量に合わせる。

## 命名規約
- 事実テーブル: `fact_*`
- ディメンション: `dim_*`
- 共通中間モデル: `core_*`
- マート: `mart_*`

## 判断基準
- 指標と属性が混在する設計は分離する。
- 再処理時に結果不一致となる実装は却下する。
- 同一概念の重複定義はSSOT観点で統合する。

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
- 粒度未定義で実装に着手すること
- Lineage不明なまま本番運用すること
- append-onlyで重複を許容すること
