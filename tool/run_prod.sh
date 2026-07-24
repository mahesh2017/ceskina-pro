#!/usr/bin/env bash
# Run the app against the production Supabase backend.
# Usage: tool/run_prod.sh [extra flutter run args, e.g. -d <device-id>]
set -euo pipefail
cd "$(dirname "$0")/.."
exec flutter run --dart-define-from-file=env/prod.json "$@"
