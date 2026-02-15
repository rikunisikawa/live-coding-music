#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
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

cd "${ROOT_DIR}"

docker compose --env-file "${ENV_FILE}" run --rm dbt dbt "$@"
