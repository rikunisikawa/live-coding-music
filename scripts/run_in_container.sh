#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

usage() {
  echo "使い方: scripts/run_in_container.sh [dbt|terraform]"
}

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

TARGET="$1"

case "${TARGET}" in
  dbt)
    docker compose run --rm dbt bash scripts/run_dbt.sh
    ;;
  terraform)
    docker compose run --rm terraform bash scripts/run_terraform_plan.sh
    ;;
  *)
    usage
    exit 1
    ;;
esac
