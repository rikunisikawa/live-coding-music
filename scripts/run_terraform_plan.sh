#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_DIR="${ROOT_DIR}/packages/infra/environments/dev"
BACKEND_CFG="${ROOT_DIR}/configs/terraform_backend.hcl"
BACKEND_EXAMPLE="${ROOT_DIR}/configs/terraform_backend.hcl.example"

if [[ ! -f "${BACKEND_CFG}" ]]; then
  echo "backend 設定が見つかりません: ${BACKEND_CFG}"
  echo "${BACKEND_EXAMPLE} を参考に ${BACKEND_CFG} を作成してください。"
  exit 1
fi

cd "${TF_DIR}"

terraform init -input=false -backend-config="${BACKEND_CFG}"
terraform plan
