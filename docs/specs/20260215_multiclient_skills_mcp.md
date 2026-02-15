# マルチクライアント共通Skills/MCP基盤の設計と実装

## 0. Spec ID
- spec_id: `20260215_multiclient_skills_mcp`

## 1. 背景
- Codex Web / Codex CLI / Gemini CLI / Claude Code で同一のSkillsを再利用できる構成が必要。
- MCPをrepo共通（HTTP）とローカル専用に分離し、移植性と安全性を確保したい。

## 2. 目的
- `.agents/skills/` 配下に共通Skillsを配置し、Gitで一元管理する。
- instruction-first設計で、必要最小限のみMCP依存を追加する。

## 3. スコープ
- 5つのSkill生成
- 必要な `agents/openai.yaml` 生成
- `.agents/README.md` で利用方法とMCP分離方針を定義

## 4. 非スコープ
- ローカル専用MCP（aws/docker/terraform/dbt-cli）の実体設定ファイルをrepoに含めること
- HTTP MCPサーバのデプロイ

## 5. 要件
### 5.1 機能要件
- Skills配置は `.agents/skills/` 固定。
- 各Skillは frontmatter と必須セクションを持つ `SKILL.md` を提供。
- 生成対象Skill: `athena_dbt_design`, `dbt_modeling`, `data_platform_architecture`, `naming_convention`, `repo_structure`。
- HTTP MCPを利用するSkillのみ `agents/openai.yaml` を持つ。

### 5.2 非機能要件
- ローカル依存をrepoから分離。
- ドキュメントは日本語。
- 再利用可能かつ単一責任原則を維持。

## 6. 設計方針
### 6.1 Grain
- 1 Skill = 1責務 = 1ディレクトリ。

### 6.2 Facts and Dimensions
- Fact: Skill定義、MCP依存定義、利用手順。
- Dimension: クライアント種別（Codex/Gemini/Claude）、MCP種別（HTTP/ローカル）。

### 6.3 Layering (Raw/Core/Mart)
- Raw: ユーザー要求
- Core: Skill定義（SKILL.md）
- Mart: 実運用メタ（openai.yaml、README）

### 6.4 Lineage
- 要件 -> Spec -> Skills生成 -> クライアント共通利用

### 6.5 Partition Strategy
- Skill単位ディレクトリ分割で変更影響を局所化。

### 6.6 Scalability Considerations
- instruction-only中心にし、必要時のみMCP依存を宣言して拡張性を確保。

## 7. 受け入れ条件（Acceptance Criteria）
- [ ] `.agents/skills/` に5Skillが存在する
- [ ] 各SKILL.mdに必須frontmatterと6セクションがある
- [ ] HTTP MCP依存を `openai.yaml` に定義できる
- [ ] ローカル専用MCPはREADME上の手順化のみに留める
- [ ] Codex/Gemini/Claudeそれぞれの利用例がある

## 8. 実装タスク
1. ディレクトリ構成作成
2. 5SkillのSKILL.md作成
3. 必要Skillへ `agents/openai.yaml` 作成
4. `.agents/README.md` 作成

## 9. テスト計画
- 手動確認: `find .agents -maxdepth 4 -type f | sort`
- 手動確認: `rg -n "^---$|^name:|^description:|^## 設計原則|^## 実装ルール|^## 命名規約|^## 判断基準|^## 出力フォーマット|^## 禁止事項" .agents/skills`

## 10. リスクと対策
- リスク: 各ツールの自動検出仕様差異
- 対策: `.agents/skills/` に統一し、READMEでツール別参照手順を明記

## 11. 未確定事項
- HTTP MCPの実URL（環境ごとの値）

## 12. 変更履歴
- 2026-02-15: 初版作成
