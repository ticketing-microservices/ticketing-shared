#!/usr/bin/env bash
set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

usage() {
  cat <<EOF
Usage:
  VERSION=1.2.3 ./ci/pack.sh
  ./ci/pack.sh --version 1.2.3

Notes:
  - Packs only projects under ./src with <IsPackable>true</IsPackable>
  - Output: ./artifacts
EOF
}

VERSION="${VERSION:-}"

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --version|-v)
      VERSION="${2:-}"
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      die "Unknown argument: $1 (use --help)"
      ;;
  esac
done

[[ -n "$VERSION" ]] || die "VERSION is required. Use VERSION=1.2.3 ./ci/pack.sh or ./ci/pack.sh --version 1.2.3"

require_cmd dotnet

ARTIFACTS_DIR="$ROOT_DIR/artifacts"
ensure_dir "$ARTIFACTS_DIR"

log "Packing NuGet packages"
log "Root: $ROOT_DIR"
log "Version: $VERSION"
log "Artifacts: $ARTIFACTS_DIR"

# Find csproj under src (excluding bin/obj)
mapfile -t CSPROJ_FILES < <(
  find "$ROOT_DIR/src" -type f -name "*.csproj" \
    -not -path "*/bin/*" -not -path "*/obj/*" \
    | sort
)

[[ ${#CSPROJ_FILES[@]} -gt 0 ]] || die "No .csproj files found under $ROOT_DIR/src"

PACKED_COUNT=0
SKIPPED_COUNT=0

for csproj in "${CSPROJ_FILES[@]}"; do
  # Only pack projects explicitly marked as packable
  if ! grep -q "<IsPackable>true</IsPackable>" "$csproj"; then
    log "Skipping (IsPackable!=true): $csproj"
    ((SKIPPED_COUNT++)) || true
    continue
  fi

  log "Packing: $csproj"

  dotnet pack "$csproj" \
    -c Release \
    -o "$ARTIFACTS_DIR" \
    /p:PackageVersion="$VERSION" \
    /p:ContinuousIntegrationBuild=true \
    --no-build \
    --nologo

  ((PACKED_COUNT++)) || true
done

if [[ "$PACKED_COUNT" -eq 0 ]]; then
  die "No projects were packed. Ensure at least one csproj under ./src contains <IsPackable>true</IsPackable>."
fi

log "Done. Packed: $PACKED_COUNT, Skipped: $SKIPPED_COUNT"
log "Packages:"
ls -1 "$ARTIFACTS_DIR"/*.nupkg 2>/dev/null || true
