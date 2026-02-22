# Agent Teams 実行フロー

## Step 0: ブランチ作成
- 入力: `spec_id`
- 出力: `spec/<spec_id>` 形式の作業ブランチ
- 完了条件: 1 Spec につき 1 ブランチが作成済み

## Step 1: Architect Agent
- 入力: 要件・既存構成
- 出力: `architecture.md`, `terraform_design.md`, `dbt_model_design.md`
- 完了条件: 設計レビュー通過

## Step 2: Infra / Data / Backend Agent
- 入力: Architect成果物のみ
- 出力: Terraform / dbt / Python 実装
- 完了条件: 実装と自己チェック完了

## Step 3: Test Agent
- 入力: Step2実装差分
- 出力: Terraform/Python/dbt テスト
- 完了条件: テスト実行可能かつ失敗時原因記録済み

## Step 4: Review Agent
- 入力: 設計・実装・テストの全差分
- 出力: レビュー指摘、改善提案
- 完了条件: Critical/High指摘が解消済み

## Step 5: 修正
- 入力: レビュー指摘
- 出力: 修正差分、再テスト結果
- 完了条件: 再レビュー通過
