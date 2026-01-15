#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/ci/common.sh"

require_cmd dotnet

ARTIFACTS_DIR="${ARTIFACTS_DIR:-$ROOT/artifacts}"
NUGET_SOURCE="${NUGET_SOURCE:-github}"
NUGET_API_KEY="${NUGET_API_KEY:?NUGET_API_KEY not set}"

log "Publishing NuGet packages to $NUGET_SOURCE"

for pkg in "$ARTIFACTS_DIR"/*.nupkg; do
  log "Pushing $pkg"
  dotnet nuget push "$pkg" \
    --source "$NUGET_SOURCE" \
    --api-key "$NUGET_API_KEY" \
    --skip-duplicate
done
