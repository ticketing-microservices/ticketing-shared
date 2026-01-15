#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/ci/common.sh"

require_cmd dotnet
require_cmd find

VERSION="${VERSION:?VERSION not set}"
CONFIGURATION="${CONFIGURATION:-Release}"
ARTIFACTS_DIR="${ARTIFACTS_DIR:-$ROOT/artifacts}"

mkdir -p "$ARTIFACTS_DIR"

log "Packing NuGet packages (version=$VERSION)"

find "$ROOT/src" -name "*.csproj" -type f -print0 | while IFS= read -r -d '' csproj; do
  log "Packing: $csproj"
  dotnet pack "$csproj" \
    -c "$CONFIGURATION" \
    --no-build \
    /p:PackageVersion="$VERSION" \
    /p:ContinuousIntegrationBuild=true \
    -o "$ARTIFACTS_DIR"
done

log "Packages generated:"
ls -la "$ARTIFACTS_DIR"
