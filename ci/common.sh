#!/usr/bin/env bash
set -euo pipefail

# -----------------------------
# Logging helpers
# -----------------------------
log()   { echo "[INFO] $*"; }
warn()  { echo "[WARN] $*" >&2; }
error() { echo "[ERROR] $*" >&2; }

die() {
  error "$*"
  exit 1
}

# -----------------------------
# Command / env validation
# -----------------------------
require_cmd() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || die "Command '$cmd' not found. Please install it or ensure it is in PATH."
}

require_env() {
  local var="$1"
  [[ -n "${!var:-}" ]] || die "Environment variable '$var' is required but was not set."
}

# -----------------------------
# Paths
# -----------------------------
# Directory where this script lives (ci/)
CI_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$CI_DIR/.." && pwd)"

# -----------------------------
# Utilities
# -----------------------------
ensure_dir() {
  local dir="$1"
  mkdir -p "$dir"
}
