# MCP サーバー設定ガイド

## 目的
Codex / Claude / Gemini CLI のいずれでも同一の運用ができるように、MCP サーバーの導入と設定方針を統一する。

## 対象サーバー
- Filesystem MCP
- AWS MCP
- dbt MCP
- Git MCP
- Fetch MCP
- Mermaid MCP
- draw.io MCP

## 共通方針
- MCP 設定のリポジトリ正本は `configs/mcp/` とする。
- 各AIツールのローカル設定は、正本から反映して生成する（手編集を原則禁止）。
- ファイルアクセスやGit操作は最小権限で実行する。
- AWSは SigV4 対応の MCP Proxy または専用サーバー経由で接続する。

## 導入手順（概要）
1. `configs/mcp/` の正本を更新する（必要時）。
2. `scripts/setup_mcp_for_tools.sh` でツールへ反映する。
3. 接続確認を行い、必要に応じて権限を絞る。

## 設定雛形
正本は以下に保存する。
- Codex 用: `configs/mcp/codex.mcp.json`
- Claude 用: `configs/mcp/claude.mcp.json`
- Gemini CLI 用: `configs/mcp/gemini.mcp.json`
- Agent Teams 用: `configs/mcp/claude-agent-teams.mcp.json`

## 反映コマンド
- Codex CLI に反映:
  - `scripts/setup_mcp_for_tools.sh codex`
- Claude Code 設定に反映:
  - `scripts/setup_mcp_for_tools.sh claude`
  - 必要なら出力先を指定: `scripts/setup_mcp_for_tools.sh claude /path/to/mcp.json`
- Gemini CLI 設定に反映:
  - `scripts/setup_mcp_for_tools.sh gemini`
  - 必要なら出力先を指定: `scripts/setup_mcp_for_tools.sh gemini /path/to/mcp.json`

## Codex Web での利用
- Codex Web からローカル `stdio` MCP は利用できない。
- Codex Web では Skill の `agents/openai.yaml` に定義した HTTP MCP（`streamable_http`）を利用する。
- 本番URLは `https://mcp.example.com/...` を実運用URLに置換する。

## セキュリティ指針
- Filesystem MCP は必要なディレクトリに限定する。
- Git MCP は read-only を基本とし、書き込みは明示的に許可する。
- Fetch MCP は許可ドメインを限定する。
- AWS MCP は最小権限のIAMロールを使用する。

## Skills の取り扱い
Skills はツール非依存の Markdown として扱い、以下を共通参照する。
- リポジトリ内（正本）: `.agents/skills/`
- ローカル共通: `~/.codex/skills/`

各AIツールで同一の Skills を参照できるよう、MCP 設定とは独立に運用する。
