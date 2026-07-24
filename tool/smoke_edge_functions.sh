#!/usr/bin/env bash
set -euo pipefail

project_ref_value="${1:?usage: smoke_edge_functions.sh <project-ref>}"

for edge_function_name in deepseek-proxy account-data whisper-proxy; do
  http_code="$(
    curl \
      --silent \
      --output /dev/null \
      --write-out '%{http_code}' \
      --request POST \
      "https://${project_ref_value}.supabase.co/functions/v1/${edge_function_name}"
  )"
  if [[ "${http_code}" != "401" ]]; then
    echo "${edge_function_name}: expected JWT rejection, received HTTP ${http_code}"
    exit 1
  fi
  echo "${edge_function_name}: reachable and JWT-protected (HTTP ${http_code})"
done
