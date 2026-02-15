#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DBT_DIR="${ROOT_DIR}/packages/dbt"
DBT_PROFILES_DIR="${ROOT_DIR}/configs/dbt"
DBT_PROFILES_FILE="${DBT_PROFILES_DIR}/profiles.yml"
DBT_PROFILES_EXAMPLE="${DBT_PROFILES_DIR}/profiles.yml.example"

if [[ ! -f "${DBT_PROFILES_FILE}" ]]; then
  echo "profiles.yml が見つかりません: ${DBT_PROFILES_FILE}"
  echo "${DBT_PROFILES_EXAMPLE} を参考に ${DBT_PROFILES_FILE} を作成してください。"
  exit 1
fi

cd "${DBT_DIR}"

export DBT_PROFILES_DIR

dbt run

dbt test
