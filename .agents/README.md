# AIエージェント共通Skill運用

このディレクトリは、Codex Web / Codex CLI / Gemini CLI / Claude Code で共通利用するSkill定義を保持する。

## ディレクトリ構造

```text
.agents/
  skills/
    athena_dbt_design/
      SKILL.md
      agents/openai.yaml
    dbt_modeling/
      SKILL.md
      agents/openai.yaml
    data_platform_architecture/
      SKILL.md
      agents/openai.yaml
    naming_convention/
      SKILL.md
    repo_structure/
      SKILL.md
```

## 方針
- Skillは必ず `.agents/skills/` に配置する。
- Skillはinstruction-first（`SKILL.md`中心）で設計する。
- HTTP MCPのみrepo共通依存として扱う。
- ローカル専用MCPはrepoに固定せず、各開発者環境で設定する。

## 生成済みSkills
- `athena_dbt_design`: Athena + Glue + dbt + S3設計
- `dbt_modeling`: dbtモデル設計・test・incremental運用
- `data_platform_architecture`: データ基盤全体設計
- `naming_convention`: 命名規約統一
- `repo_structure`: リポジトリ構造設計
- `aws_data_platform`: AWSデータ基盤の設計・運用ベストプラクティス
- `data_engineering_design`: Grain/Fact/Dimension/Lineage等の設計原則
- `dbt_design`: dbtの設計ガイドライン

## MCP設計

### 1. repo共通MCP（HTTP）
- `agents/openai.yaml` の `dependencies.tools` に定義する。
- 例:
  - `https://mcp.example.com/dbt-metadata`
  - `https://mcp.example.com/documentation`
  - `https://mcp.example.com/schema-registry`

### 2. ローカル専用MCP（repoに含めない）
- dbt CLI execution
- docker control
- aws cli execution
- terraform execution

上記は各ユーザーのローカル設定ファイル（例: `~/.codex/`, `~/.config/`）でのみ管理し、repo依存にしない。

## 使用方法

### Codex Web
- リポジトリを開く。
- タスクに応じてSkill名を明示する（例: `athena_dbt_design`）。
- 必要に応じて `agents/openai.yaml` のHTTP MCPを参照させる。

### Codex CLI
- リポジトリ直下で起動する。
- 例:
  - `codex "athena_dbt_design を使ってAthenaテーブル設計を提案して"`
  - `codex "dbt_modeling を使ってcoreモデルとschema.ymlを更新して"`

### Gemini CLI
- リポジトリをワークスペースとして開く。
- `.agents/skills/` 配下の `SKILL.md` を参照して実装指示する。
- 例:
  - `gemini "Use .agents/skills/naming_convention/SKILL.md and review naming issues"`

### Claude Code
- リポジトリルートで作業する。
- `.agents/skills/<skill>/SKILL.md` を明示して指示する。
- 例:
  - `claude "repo_structure の規約に従ってディレクトリ再編案を出して"`

## 運用ルール
- Skill変更はPRでレビューし、repoでバージョン管理する。
- ローカル専用MCP設定はPR対象外にする。
- 新規Skill追加時は単一責任原則を守る。
