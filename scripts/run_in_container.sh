#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

usage() {
  echo "使い方: scripts/run_in_container.sh [dbt|terraform-plan|terraform-apply]"
}

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

TARGET="$1"
ENV_FILE="${ROOT_DIR}/.env"

if [[ ! -f "${ENV_FILE}" ]]; then
  echo ".env が見つかりません: ${ENV_FILE}"
  echo ".env.example を参考に .env を作成してください。"
  exit 1
fi

set -a
source "${ENV_FILE}"
set +a

if [[ -z "${APP_ENV:-}" ]]; then
  echo "APP_ENV が未設定です。dev または prod を設定してください。"
  exit 1
fi

case "${TARGET}" in
  dbt)
    docker compose --env-file "${ENV_FILE}" run --rm dbt bash scripts/run_dbt.sh
    ;;
  terraform-plan)
    docker compose --env-file "${ENV_FILE}" run --rm terraform bash scripts/run_terraform_plan.sh
    ;;
  terraform-apply)
    docker compose --env-file "${ENV_FILE}" run --rm terraform bash scripts/run_terraform_apply.sh
    ;;
  *)
    usage
    exit 1
    ;;
esac
