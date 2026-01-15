#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/ci/common.sh"

require_cmd dotnet
require_cmd find

VERSION="${VERSION:?VERSION not set (e.g. 1.2.3)}"
CONFIGURATION="${CONFIGURATION:-Release}"
ARTIFACTS_DIR="${ARTIFACTS_DIR:-$ROOT/artifacts}"

mkdir -p "$ARTIFACTS_DIR"

log "Packing NuGet packages (version=$VERSION)"

EXCLUDE_REGEX='(\/test\/|\/tests\/|\.Tests\.|\/API\/|\.API\.|\/Host\/|\/Infrastructure\/|\.Infrastructure\.)'

mapfile -t CSPROJS < <(find "$ROOT/src" -name "*.csproj" -type f | sort)

if [ ${#CSPROJS[@]} -eq 0 ]; then
  die "No .csproj files found under $ROOT/src"
fi

packed=0
skipped=0

for csproj in "${CSPROJS[@]}"; do
  if [[ "$csproj" =~ $EXCLUDE_REGEX ]]; then
    warn "Skipping (excluded by regex): $csproj"
    skipped=$((skipped + 1))
    continue
  fi

  log "Packing: $csproj"
  dotnet pack "$csproj" \
    -c "$CONFIGURATION" \
    --no-build \
    /p:PackageVersion="$VERSION" \
    /p:ContinuousIntegrationBuild=true \
    -o "$ARTIFACTS_DIR"

  packed=$((packed + 1))
done

log "Pack summary: packed=$packed, skipped=$skipped"
log "Packages generated in: $ARTIFACTS_DIR"
ls -la "$ARTIFACTS_DIR"
