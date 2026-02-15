---
name: aws_data_platform
description: AWSデータ基盤（S3/Glue/Redshift/Athena）の設計・運用判断が必要な場合に使用する。特にパーティション、ETL冪等性、性能/コスト最適化の検討時に適用する。
---

## 設計原則
- Raw/Core/Martの責務分離を維持する。
- クエリパターン起点でストレージ設計する。
- スキーマ変更に強い構造を優先する。

## 実装ルール
- S3はフィルタ条件に合わせてパーティション設計する。
- ETLは再実行可能（idempotent）に実装する。
- Glue ETLは変換をモジュール化し、データ契約を明記する。
- 高頻度参照データは圧縮/列指向形式を優先する。

## 命名規約
- S3パーティション: `dt=YYYY-MM-DD`
- DB/Schema/Table: snake_case
- モデル名: レイヤを示す接頭辞を付ける

## 判断基準
- スキャン量増大が見込まれる場合は代替パーティションを提案する。
- 遅延到着データがある場合はバックフィル戦略を必須化する。
- コスト増が見込まれる変更は抑制策を同時提示する。

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
- 冪等性を満たさないETL実装
- パーティション戦略なしの大規模テーブル追加
- 監視項目未定義の運用投入
