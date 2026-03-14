#!/usr/bin/env bash

set -euo pipefail

service_account_json="${INPUT_SERVICE_ACCOUNT_JSON:-}"
profile="${INPUT_PROFILE:-default}"
developer_id="${INPUT_DEVELOPER_ID:-}"
binary_path="${GPC_BINARY_PATH:-gpc}"

if [[ -z "${service_account_json}" ]]; then
  {
    echo "auth-configured=false"
    echo "service-account-path="
  } >>"${GITHUB_OUTPUT}"
  exit 0
fi

service_account_path="${RUNNER_TEMP:-/tmp}/setup-gpc/service-account-${profile}.json"
mkdir -p "$(dirname "${service_account_path}")"
printf '%s' "${service_account_json}" >"${service_account_path}"

{
  echo "GPC_BYPASS_KEYCHAIN=1"
  echo "GPC_SERVICE_ACCOUNT=${service_account_path}"
} >>"${GITHUB_ENV}"
export GPC_BYPASS_KEYCHAIN=1
export GPC_SERVICE_ACCOUNT="${service_account_path}"

args=("${binary_path}" auth init --service-account "${service_account_path}" --profile "${profile}")
if [[ -n "${developer_id}" ]]; then
  args+=(--developer-id "${developer_id}")
fi
"${args[@]}"

{
  echo "auth-configured=true"
  echo "service-account-path=${service_account_path}"
} >>"${GITHUB_OUTPUT}"
