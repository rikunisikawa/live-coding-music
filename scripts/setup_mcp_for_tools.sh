#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CODEX_CONFIG_TEMPLATE="${ROOT_DIR}/configs/mcp/codex.mcp.json"
CLAUDE_CONFIG_TEMPLATE="${ROOT_DIR}/configs/mcp/claude.mcp.json"
GEMINI_CONFIG_TEMPLATE="${ROOT_DIR}/configs/mcp/gemini.mcp.json"

usage() {
  cat <<'USAGE'
使い方:
  scripts/setup_mcp_for_tools.sh help
  scripts/setup_mcp_for_tools.sh codex
  scripts/setup_mcp_for_tools.sh claude [target_path]
  scripts/setup_mcp_for_tools.sh gemini [target_path]

説明:
- codex: codex mcp add で repo定義のMCPを ~/.codex/config.toml に登録
- claude: configs/mcp/claude.mcp.json を指定パスへコピー
- gemini: configs/mcp/gemini.mcp.json を指定パスへコピー

デフォルト出力先:
- claude: ~/.claude/mcp.json
- gemini: ~/.gemini/mcp.json
USAGE
}

copy_config() {
  local source="$1"
  local target="$2"

  mkdir -p "$(dirname "${target}")"
  cp "${source}" "${target}"
  echo "設定をコピーしました: ${target}"
}

setup_codex() {
  if ! command -v codex >/dev/null 2>&1; then
    echo "codex コマンドが見つかりません。"
    exit 1
  fi

  # 重複定義を避けるため、同名サーバは一度削除して再登録する。
  codex mcp remove filesystem >/dev/null 2>&1 || true
  codex mcp remove aws >/dev/null 2>&1 || true
  codex mcp remove dbt >/dev/null 2>&1 || true
  codex mcp remove git >/dev/null 2>&1 || true
  codex mcp remove fetch >/dev/null 2>&1 || true
  codex mcp remove mermaid >/dev/null 2>&1 || true
  codex mcp remove drawio >/dev/null 2>&1 || true

  codex mcp add filesystem \
    --env MCP_TRANSPORT_TYPE=stdio \
    --env MCP_TRANSPORT=stdio \
    --env MCP_PROJECT_ROOT="${ROOT_DIR}" \
    -- npx -y @cyanheads/filesystem-mcp-server@latest

  codex mcp add aws \
    --env AWS_REGION=ap-northeast-1 \
    --env AWS_API_MCP_PROFILE_NAME=default \
    --env AWS_API_MCP_TRANSPORT=stdio \
    -- uvx awslabs.aws-api-mcp-server@latest

  codex mcp add dbt \
    --env DBT_PROJECT_DIR="${ROOT_DIR}/packages/dbt" \
    --env DBT_PATH="${ROOT_DIR}/scripts/dbt_cli.sh" \
    -- uvx dbt-mcp

  codex mcp add git \
    --env MCP_TRANSPORT_TYPE=stdio \
    --env MCP_TRANSPORT=stdio \
    --env MCP_LOG_LEVEL=info \
    --env GIT_BASE_DIR="${ROOT_DIR}" \
    --env GIT_SIGN_COMMITS=false \
    -- npx -y @cyanheads/git-mcp-server@latest

  codex mcp add fetch \
    --env FETCH_ALLOWLIST=docs.aws.amazon.com,aws.amazon.com,awslabs.github.io,docs.getdbt.com,github.com,zenn.dev,qiita.com \
    -- uvx mcp-server-fetch

  codex mcp add mermaid -- uvx --from mcp-mermaid-image-gen mcp_mermaid_image_gen
  codex mcp add drawio -- npx -y @drawio/mcp

  echo "Codex MCP設定を反映しました。"
  echo "確認: codex mcp list"
}

COMMAND="${1:-help}"

case "${COMMAND}" in
  help|-h|--help)
    usage
    ;;
  codex)
    setup_codex
    ;;
  claude)
    TARGET="${2:-${HOME}/.claude/mcp.json}"
    copy_config "${CLAUDE_CONFIG_TEMPLATE}" "${TARGET}"
    ;;
  gemini)
    TARGET="${2:-${HOME}/.gemini/mcp.json}"
    copy_config "${GEMINI_CONFIG_TEMPLATE}" "${TARGET}"
    ;;
  *)
    echo "不明なコマンドです: ${COMMAND}"
    usage
    exit 1
    ;;
esac
