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
      case "$install_version" in
        latest|master)
          printf 'master\n'
          ;;
        *)
          fail "only 'latest' is supported until Spinel publishes version tags"
          ;;
      esac
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
  printf 'latest\nmaster\n'
}

latest_stable_version() {
  printf 'latest\n'
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
