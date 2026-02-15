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
- ツール非依存で運用するため、設定は `configs/mcp/` に雛形として保存する。
- 各AIツールの設定ファイルへは、雛形をコピーし、必要なパスやコマンドを埋める。
- ファイルアクセスやGit操作は最小権限で実行する。
- AWSは SigV4 対応の MCP Proxy または専用サーバー経由で接続する。

## 導入手順（概要）
1. 対象ツールに合わせて `configs/mcp/*.mcp.json` をコピーする。
2. `command` と `args` を利用環境に合わせて具体化する。
3. 必要な環境変数を `.env` または各ツール設定に反映する。
4. 接続確認を行い、必要に応じて権限を絞る。

## 設定雛形
雛形は以下に保存する。
- Codex 用: `configs/mcp/codex.mcp.json`
- Claude 用: `configs/mcp/claude.mcp.json`
- Gemini CLI 用: `configs/mcp/gemini.mcp.json`

雛形には `CHANGE_ME` が含まれる。利用環境の実行コマンドへ置き換えること。

## セキュリティ指針
- Filesystem MCP は必要なディレクトリに限定する。
- Git MCP は read-only を基本とし、書き込みは明示的に許可する。
- Fetch MCP は許可ドメインを限定する。
- AWS MCP は最小権限のIAMロールを使用する。

## Skills の取り扱い
Skills はツール非依存の Markdown として扱い、以下を共通参照する。
- リポジトリ内: `ai/skills/`
- ローカル共通: `~/.codex/skills/`

各AIツールで同一の Skills を参照できるよう、MCP 設定とは独立に運用する。
