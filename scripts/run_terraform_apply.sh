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

TF_DIR="${ROOT_DIR}/packages/infra"
BACKEND_CFG="${ROOT_DIR}/configs/terraform_backend.${APP_ENV}.hcl"
BACKEND_FALLBACK="${ROOT_DIR}/configs/terraform_backend.hcl"
BACKEND_EXAMPLE="${ROOT_DIR}/configs/terraform_backend.hcl.example"
VAR_FILE="${ROOT_DIR}/packages/infra/env/${APP_ENV}.tfvars"

if [[ ! -f "${BACKEND_CFG}" ]]; then
  if [[ "${APP_ENV}" == "dev" && -f "${BACKEND_FALLBACK}" ]]; then
    BACKEND_CFG="${BACKEND_FALLBACK}"
  else
    echo "backend 設定が見つかりません: ${BACKEND_CFG}"
    echo "${BACKEND_EXAMPLE} を参考に ${BACKEND_CFG} を作成してください。"
    exit 1
  fi
fi

if [[ ! -f "${VAR_FILE}" ]]; then
  echo "var-file が見つかりません: ${VAR_FILE}"
  exit 1
fi

cd "${TF_DIR}"

terraform init -input=false -backend-config="${BACKEND_CFG}"
terraform apply -auto-approve -var-file="${VAR_FILE}"
