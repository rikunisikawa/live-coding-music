---
name: data_platform_architecture
description: AWSデータ基盤全体（S3/Glue/Athena/dbt/運用）の構成設計、責務分離、拡張性・監視・コスト最適化の判断が必要な場合に使用する。
---

## 設計原則
- Raw/Core/Mart の責務を分離する。
- データ契約とLineageを明示する。
- セキュリティ・可観測性・コストを同時に設計する。

## 実装ルール
- S3は用途別バケット/プレフィックスで分離する。
- Glue Catalogは命名規約に従い一貫管理する。
- 監視項目（失敗率、遅延、スキャン量）を設計時に定義する。
- 運用Runbook更新を実装タスクに含める。

## 命名規約
- S3: `<domain>-<layer>-<env>`
- Glue DB: `<domain>_<layer>`
- Terraform変数: `snake_case`

## 判断基準
- 再利用可能な機能は共通レイヤへ配置する。
- 監査対象データはRaw保存を必須にする。
- コスト増が見込まれる設計は事前に抑制策を提示する。
- ローカル依存機能はrepo設計から分離し、手順のみ文書化する。

## 出力フォーマット
1. Summary
- 目的・スコープ

2. Design Decisions
- Grain
- Facts and Dimensions
- Layering
- Lineage
- Partition Strategy
- Scalability Considerations

3. Proposed Improvements
- 運用改善・コスト改善・監視改善

4. Implementation
- 変更対象（IaC/SQL/Docs）
- 検証手順

## 禁止事項
- 監視設計なしで基盤変更を導入すること。
- SSOTを壊す重複レイヤを追加すること。
- ローカル専用MCPをrepo必須依存にすること。
