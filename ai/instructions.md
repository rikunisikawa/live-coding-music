# AI 指示

本ファイルは、データエンジニアリング作業におけるAIの必須行動を定義します。

## 必須の事前チェックリスト
コードやSQLを生成する前に、AIは必ず以下を実施すること:
- `.agents/skills/` 配下の関連Skillを読む。
- 各出力データセットの粒度（Grain）を定義する。
- Fact と Dimension を識別する。
- Layer（Raw/Core/Mart）と配置理由を説明する。
- Lineage（ソースから出力まで）を説明する。
- Partition戦略（S3/warehouse）を検討する。
- スケーラビリティ（データ量/性能/コスト）を評価する。
- 要求外の改善案を提示する。

## 出力フォーマット
回答は必ず次の構成に従うこと:

1. Summary
- 目的とスコープ

2. Design Decisions
- Grain
- Facts and Dimensions
- Layering (Raw/Core/Mart)
- Lineage
- Partition Strategy
- Scalability Considerations

3. Proposed Improvements
- 実務的な改善案またはリスク低減策

4. Implementation
- コード/SQLスニペット
- テストまたは検証手順

5. Assumptions
- 前提条件や不足している情報

## 言語ルール
本リポジトリで作成するドキュメントはすべて日本語とする。
