#!/usr/bin/env bash

set -euo pipefail

TOOL_NAME="spinel"

SPINEL_GITHUB_REPO="${SPINEL_GITHUB_REPO:-matz/spinel}"
SPINEL_SOURCE_URL="https://github.com/${SPINEL_GITHUB_REPO}"

fail() {
  echo "asdf-${TOOL_NAME}: $*" >&2
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "required command not found: $1"
}

version_ref() {
  local install_type="$1"
  local install_version="$2"

  case "$install_type" in
    version)
      [ "$install_version" = "master" ] || fail "only master is listed until Spinel publishes version tags"
      printf 'master\n'
      ;;
    ref)
      printf '%s\n' "$install_version"
      ;;
    *)
      fail "unsupported install type: $install_type"
      ;;
  esac
}

list_versions() {
  printf 'master\n'
}

latest_stable_version() {
  local query="${1:-}"

  if [ "$query" = "" ] || [ "$query" = "master" ]; then
    printf 'master\n'
  fi
}

download_source() {
  local ref="$1"
  local destination="$2"
  local archive

  require_cmd curl
  require_cmd tar

  archive="$(mktemp)"
  curl -fL "${SPINEL_SOURCE_URL}/archive/${ref}.tar.gz" -o "$archive"

  mkdir -p "$destination"
  tar -xzf "$archive" -C "$destination" --strip-components=1
  rm -f "$archive"
}
