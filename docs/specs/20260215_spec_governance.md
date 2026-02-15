# Spec駆動運用ルールの追加

## 0. Spec ID
- spec_id: `20260215_spec_governance`

## 1. 背景
- Spec駆動開発を実運用で徹底するため、PR・コミット・命名規則を統一したい。

## 2. 目的
- PR本文、コミットメッセージ、Specファイル名の規約を明文化し、運用漏れを防ぐ。

## 3. スコープ
- Spec運用ワークフローの追記
- PRテンプレート追加
- Gitサイクルスクリプトの規約対応

## 4. 非スコープ
- CIによる自動バリデーション追加

## 5. 要件
### 5.1 機能要件
- PR本文にSpecパスを必須化する。
- コミットメッセージを `spec:<spec_id> <内容>` 形式にする。
- Specファイル名を `YYYYMMDD_snake_case.md` に統一する。

### 5.2 非機能要件
- 運用ルールは日本語で文書化する。
- 既存フローに最小限の追加で適用する。

## 6. 設計方針
### 6.1 Grain
- 1変更要求（PR）を1主要Specで管理する。

### 6.2 Facts and Dimensions
- Fact: コミット、PR、Specファイル。
- Dimension: spec_id、ブランチ、日時。

### 6.3 Layering (Raw/Core/Mart)
- Raw: 要求
- Core: Spec運用ルール
- Mart: 実行スクリプトとPRテンプレート

### 6.4 Lineage
- 要求 -> Spec作成 -> 実装 -> PR

### 6.5 Partition Strategy
- 日付プレフィックス（YYYYMMDD）でSpecを分類する。

### 6.6 Scalability Considerations
- 命名規則固定により検索性と追跡性を確保する。

## 7. 受け入れ条件（Acceptance Criteria）
- [x] PRテンプレートにSpec欄がある
- [x] run_git_cycleがspec_idを必須化している
- [x] 規約がREADME/AGENT/Workflowに明記されている

## 8. 実装タスク
1. `docs/spec_workflow.md` 更新
2. `docs/spec_template.md` 更新
3. `.github/pull_request_template.md` 追加
4. `scripts/run_git_cycle.sh` 更新

## 9. テスト計画
- 単体テスト: `bash -n scripts/run_git_cycle.sh`
- 手動確認: `scripts/run_git_cycle.sh -h`

## 10. リスクと対策
- リスク: 規約未遵守
- 対策: PRテンプレートとスクリプトでガード

## 11. 未確定事項
- CIでの規約チェック導入時期

## 12. 変更履歴
- 2026-02-15: 初版作成
