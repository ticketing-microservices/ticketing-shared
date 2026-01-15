#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/ci/common.sh"

require_cmd dotnet

ARTIFACTS_DIR="${ARTIFACTS_DIR:-$ROOT/artifacts}"
NUGET_SOURCE="${NUGET_SOURCE:-github}"
NUGET_API_KEY="${NUGET_API_KEY:?NUGET_API_KEY not set}"

shopt -s nullglob
pkgs=("$ARTIFACTS_DIR"/*.nupkg)
shopt -u nullglob

if [ ${#pkgs[@]} -eq 0 ]; then
  die "No .nupkg found in $ARTIFACTS_DIR"
fi

log "Publishing ${#pkgs[@]} package(s) to source: $NUGET_SOURCE"

for pkg in "${pkgs[@]}"; do
  log "Pushing $pkg"
  dotnet nuget push "$pkg" \
    --source github-ticketing \
    --api-key "$NUGET_API_KEY" \
    --skip-duplicate  
done

log "Publish completed."
