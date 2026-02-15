# Skillsフォルダ統合（ai/skills -> .agents/skills）

## 0. Spec ID
- spec_id: `20260215_skills_folder_unification`

## 1. 背景
- 現在 `ai/skills` と `.agents/skills` に知識が分散し、正本が曖昧。
- Codex/Gemini/Claudeで共通参照するには単一フォルダへの統合が必要。

## 2. 目的
- Skillsの正本を `.agents/skills/` に統一する。
- 既存の `ai/skills` 内容を欠落なく移行する。
- ドキュメント参照先を一本化する。

## 3. スコープ
- `ai/skills/*.md` を `.agents/skills/<name>/SKILL.md` へ移管
- `ai/instructions.md`, `README.md`, `AGENT.md`, `docs/mcp_setup.md` の参照更新
- `ai/skills/` の旧ファイル削除

## 4. 非スコープ
- ローカル共通 Skills（`~/.codex/skills/`）の削除・変更
- 各CLI製品側の検出ロジック変更

## 5. 要件
### 5.1 機能要件
- Skill正本は `.agents/skills/` のみとする。
- 既存3Skill（aws-data-platform/data-engineering-design/dbt-design）を移行する。
- ドキュメント上で統一方針を明記する。

### 5.2 非機能要件
- 既存知識を欠落させない。
- 命名はsnake_caseで統一する。
- ドキュメントは日本語で記載する。

## 6. 設計方針
### 6.1 Grain
- 1 Skill = 1ディレクトリ = 1 SKILL.md

### 6.2 Facts and Dimensions
- Fact: Skill定義ファイル
- Dimension: 配置先、参照先、クライアント

### 6.3 Layering (Raw/Core/Mart)
- Raw: 既存 `ai/skills` 内容
- Core: `.agents/skills` のSKILL.md
- Mart: ガイド文書の参照先

### 6.4 Lineage
- ai/skills -> .agents/skills -> 各CLI参照

### 6.5 Partition Strategy
- Skill単位ディレクトリで管理

### 6.6 Scalability Considerations
- 単一正本化により重複更新コストと運用ミスを削減

## 7. 受け入れ条件（Acceptance Criteria）
- [ ] `ai/skills` にskill本文が存在しない
- [ ] `.agents/skills` に移行後のskillが存在する
- [ ] 主要ドキュメントの参照先が `.agents/skills` に統一される

## 8. 実装タスク
1. 既存3Skillを `.agents/skills` へ変換
2. 参照ドキュメント更新
3. 旧 `ai/skills` 削除
4. 整合性確認

## 9. テスト計画
- `find .agents/skills -maxdepth 2 -name SKILL.md | sort`
- `rg -n "ai/skills|\.agents/skills" README.md AGENT.md ai/instructions.md docs/mcp_setup.md`

## 10. リスクと対策
- リスク: 既存ツールが `ai/skills` を固定参照
- 対策: `ai/instructions.md` を更新し、統一先を明記

## 11. 未確定事項
- なし

## 12. 変更履歴
- 2026-02-15: 初版作成
