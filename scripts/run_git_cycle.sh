#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

usage() {
  cat <<'USAGE'
使い方:
  scripts/run_git_cycle.sh -s "<spec_id>" -m "コミットメッセージ" [-t "PRタイトル"] [-b "ベースブランチ"]

例:
  scripts/run_git_cycle.sh -s "20260215_git_pr_cycle" -m "dbtモデルの追加" -t "dbtモデル追加と運用更新"
  scripts/run_git_cycle.sh -s "20260215_tfvars_refactor" -m "Terraform変数整理" -b "main"
USAGE
}

SPEC_ID=""
COMMIT_MESSAGE=""
PR_TITLE=""
BASE_BRANCH=""

while getopts ":s:m:t:b:h" opt; do
  case "${opt}" in
    s)
      SPEC_ID="${OPTARG}"
      ;;
    m)
      COMMIT_MESSAGE="${OPTARG}"
      ;;
    t)
      PR_TITLE="${OPTARG}"
      ;;
    b)
      BASE_BRANCH="${OPTARG}"
      ;;
    h)
      usage
      exit 0
      ;;
    :)
      echo "オプション -${OPTARG} に値が必要です。"
      usage
      exit 1
      ;;
    \?)
      echo "不明なオプションです: -${OPTARG}"
      usage
      exit 1
      ;;
  esac
done

if [[ -z "${SPEC_ID}" ]]; then
  echo "Spec ID を指定してください。"
  usage
  exit 1
fi

if [[ ! "${SPEC_ID}" =~ ^[0-9]{8}_[a-z0-9_]+$ ]]; then
  echo "Spec ID の形式が不正です: ${SPEC_ID}"
  echo "形式: YYYYMMDD_snake_case（例: 20260215_git_pr_cycle）"
  exit 1
fi

SPEC_PATH="docs/specs/${SPEC_ID}.md"
if [[ ! -f "${SPEC_PATH}" ]]; then
  echo "Spec ファイルが見つかりません: ${SPEC_PATH}"
  echo "先に Spec を作成してから実行してください。"
  exit 1
fi

if [[ -z "${COMMIT_MESSAGE}" ]]; then
  echo "コミットメッセージを指定してください。"
  usage
  exit 1
fi

FINAL_COMMIT_MESSAGE="${COMMIT_MESSAGE}"
if [[ ! "${COMMIT_MESSAGE}" =~ ^spec:${SPEC_ID}[[:space:]] ]]; then
  FINAL_COMMIT_MESSAGE="spec:${SPEC_ID} ${COMMIT_MESSAGE}"
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "gh コマンドが見つかりません。GitHub CLI をインストールしてください。"
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "gh 認証が未設定です。先に 'gh auth login' を実行してください。"
  exit 1
fi

CURRENT_BRANCH="$(git branch --show-current)"
if [[ -z "${CURRENT_BRANCH}" ]]; then
  echo "detached HEAD では実行できません。作業ブランチに切り替えてください。"
  exit 1
fi

if [[ -z "${BASE_BRANCH}" ]]; then
  DEFAULT_REMOTE_HEAD="$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null || true)"
  if [[ -n "${DEFAULT_REMOTE_HEAD}" ]]; then
    BASE_BRANCH="${DEFAULT_REMOTE_HEAD#origin/}"
  else
    BASE_BRANCH="main"
  fi
fi

if [[ "${CURRENT_BRANCH}" == "${BASE_BRANCH}" ]]; then
  echo "現在ブランチ (${CURRENT_BRANCH}) がベースブランチと同一です。"
  echo "PR作成のため、先に作業ブランチを作成してください。"
  exit 1
fi

if [[ -z "${PR_TITLE}" ]]; then
  PR_TITLE="${COMMIT_MESSAGE}"
fi

if [[ ! "${PR_TITLE}" =~ ^\[${SPEC_ID}\] ]]; then
  PR_TITLE="[${SPEC_ID}] ${PR_TITLE}"
fi

echo "[1/4] 変更をステージングします"
git add -A

echo "[2/4] コミットを作成します"
if git diff --cached --quiet; then
  echo "ステージ済み変更がないため、コミット作成をスキップします。"
else
  git commit -m "${FINAL_COMMIT_MESSAGE}"
fi

echo "[3/4] リモートへ push します"
if git rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1; then
  git push
else
  git push -u origin "${CURRENT_BRANCH}"
fi

echo "[4/4] PRを作成または確認します"
EXISTING_PR_URL="$(gh pr view --json url --jq .url 2>/dev/null || true)"
if [[ -n "${EXISTING_PR_URL}" ]]; then
  echo "既存のPRがあります: ${EXISTING_PR_URL}"
  exit 0
fi

PR_BODY_FILE="$(mktemp)"
trap 'rm -f "${PR_BODY_FILE}"' EXIT

cat > "${PR_BODY_FILE}" <<PRBODY
Spec: ${SPEC_PATH}

## 概要
- 変更内容を記載してください

## 変更内容
- 主要な差分を記載してください

## 確認観点
- レビュアーに見てほしいポイントを記載してください
PRBODY

gh pr create \
  --base "${BASE_BRANCH}" \
  --head "${CURRENT_BRANCH}" \
  --title "${PR_TITLE}" \
  --body-file "${PR_BODY_FILE}"
