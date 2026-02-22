# Claude Code Agent Teams 導入仕様（医療データ基盤）

## 0. Spec ID
- spec_id: `20260221_claude_code_agent_teams_medical_platform`
- branch_name: `spec/20260221_claude_code_agent_teams_medical_platform`

## 1. Summary
- 目的: AWS・Terraform・dbt・Python・CI/CD を用いた医療データ基盤開発において、AIエージェントの設計/実装/テスト/レビューを完全分業化し、人間は意思決定に専念できる運用を実現する。
- スコープ: Agent Teams 定義、役割境界、通信ルール、Skill体系、MCP利用方針、実行フロー、成果物標準。

## 2. Design Decisions
### Grain
- 1実行単位 = 1Spec（要求）に対する Step1〜Step5 完了サイクル。
- 1Agent成果物単位 = 1Agent が 1Task を処理した `Agent / Task / Output / Next Action` レコード。

### Facts and Dimensions
- Fact:
  - 設計成果物（architecture, terraform design, dbt model design）
  - 実装成果物（terraform, dbt, python）
  - 検証成果物（tests, review comments）
- Dimension:
  - agent_name, step, spec_id, environment(dev/stg/prod), aws_account, dataset_domain

### Layering (Raw/Core/Mart)
- Raw: ソース生データ（S3 Raw）
- Core: 統合済み標準モデル（dbt core）
- Mart: 医療指標/利用目的別データマート（dbt mart）
- 本Specではレイヤを「Architect設計で固定し、Data Agentが実装」する。

### Lineage
- 要件/Spec
  -> Architect Agent 設計
  -> Infra/Data/Backend Agent 実装
  -> Test Agent 検証
  -> Review Agent 監査
  -> 修正
  -> 承認

### Partition Strategy
- S3: `domain=<data_domain>/dt=YYYY-MM-DD` を基本とする。
- dbt/Athena/Redshift: 期間フィルタ優先キーで分割・クラスタリングを設計する。

### Scalability Considerations
- Agentごとに責務分離し、並列実装可能なStep2のみ並列化する。
- すべての実装は宣言的定義（Terraform/dbt）優先で再実行可能にする。
- Test/Review をゲート化し、本番前に自動品質判定する。

## 3. Agent Teams 構成
### Architect Agent
- 責務: システム設計、アーキテクチャ決定、Terraform構成設計、データモデル設計、AWS構成設計
- 出力: `architecture.md`, `terraform_design.md`, `dbt_model_design.md`
- 禁止: 直接実装禁止

### Infra Agent
- 責務: Terraform実装、AWSリソース作成、VPC/IAM/S3/Glue/Redshift構築
- 出力: Terraformコード、モジュールコード
- ルール: Terraformのみ使用、手動作業禁止

### Data Agent
- 責務: dbt model実装、SQL実装、データ変換処理
- 出力: dbt models, `schema.yml`, tests

### Backend Agent
- 責務: Python実装、ETL処理、Lambda処理
- 出力: Pythonコード

### Test Agent
- 責務: Terraform/Python/dbt のテスト作成、品質保証
- 出力: テストコード

### Review Agent
- 責務: コードレビュー、セキュリティレビュー、ベストプラクティス検証
- 出力: レビューコメント、改善提案

## 4. Agent Communication Rules
- Architect Agent の設計完了前に実装Agent（Infra/Data/Backend）は着手禁止。
- Infra/Data/Backend は Architect の設計ドキュメントを唯一の実装入力として扱う。
- Test Agent は全実装差分に対してテストを追加/更新する。
- Review Agent は全差分をレビューし、重大指摘が解消されるまで完了不可。

## 5. MCP Servers 利用方針
- 必須MCP: `aws`, `terraform`, `dbt`, `drawio`, `filesystem`, `git`
- 利用目的:
  - aws: 構成確認、影響範囲把握
  - terraform: IaC生成/検証
  - dbt: モデル検証/依存関係把握
  - drawio: アーキテクチャ図生成
  - filesystem: ファイル編集/構造管理
  - git: 差分確認、レビュー連携

## 6. 作業フロー
1. Step 1: Architect Agent が設計
2. Step 2: Infra / Data / Backend Agent が実装
3. Step 3: Test Agent がテスト作成
4. Step 4: Review Agent がレビュー
5. Step 5: 指摘反映と再検証

## 7. 出力形式標準
- すべてのAgent出力は以下の4項目を必須とする。

```text
Agent:
Task:
Output:
Next Action:
```

## 8. 重要制約
- 安全性優先
- AWS構築はTerraform以外禁止
- 破壊的操作禁止
- 本番環境変更前に人間承認を必須化

## 9. Proposed Improvements
- CIで Step 3/4 を必須ステータスチェック化し、未通過時はマージ不可にする。
- セキュリティ基準（IAM最小権限、暗号化、監査ログ）をPolicy as Code化する。
- 医療データ向けにPII分類タグとマスキング方針をData Agent規約へ追加する。

## 10. Implementation
- Agent定義: `.claude/agents/*.md`
- Skills: `.agents/skills/*/SKILL.md`
- 運用テンプレート: `agent-teams/`
- MCP設定: `configs/mcp/claude-agent-teams.mcp.json`

## 11. Assumptions
- Claude Code の Agent Teams は `.claude/agents/` 配下のエージェント定義を参照する前提。
- Terraform/dbt 実行環境と認証情報は別途セットアップ済み。
- 本Specは初期導入（運用テンプレート整備）を対象とし、実AWS反映は含まない。

## 12. 変更履歴
- 2026-02-21: 初版作成
