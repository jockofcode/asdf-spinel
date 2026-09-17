#!/usr/bin/env bash

set -euo pipefail

TOOL_NAME="spinel"

SPINEL_GITHUB_REPO="${SPINEL_GITHUB_REPO:-matz/spinel}"
SPINEL_SOURCE_URL="https://github.com/${SPINEL_GITHUB_REPO}"
SPINEL_GITHUB_API="https://api.github.com/repos/${SPINEL_GITHUB_REPO}"

fail() {
  echo "asdf-${TOOL_NAME}: $*" >&2
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "required command not found: $1"
}

# Fetches every page of a paginated GitHub API endpoint and prints one JSON
# value per line (via `jq -c '.[]'`) for each element across all pages.
github_api_get() {
  local url="$1"
  local auth_header=()

  if [ -n "${GITHUB_API_TOKEN:-}" ]; then
    auth_header=(-H "Authorization: token ${GITHUB_API_TOKEN}")
  elif [ -n "${GH_TOKEN:-}" ]; then
    auth_header=(-H "Authorization: token ${GH_TOKEN}")
  fi

  while [ -n "$url" ]; do
    local headers body next
    headers="$(mktemp)"
    if ! body="$(curl -fsSL -D "$headers" "${auth_header[@]+"${auth_header[@]}"}" -H "Accept: application/vnd.github+json" "$url")"; then
      rm -f "$headers"
      fail "failed to query GitHub API: ${url} (rate limited? set GITHUB_API_TOKEN)"
    fi

    printf '%s' "$body" | jq -c '.[]'

    next="$(grep -i '^link:' "$headers" | grep -o '<[^>]*>; rel="next"' | sed -E 's/^<(.*)>.*/\1/' || true)"
    rm -f "$headers"
    url="$next"
  done
}

# Non-draft, non-prerelease GitHub releases, one JSON object per line.
github_releases_json() {
  github_api_get "${SPINEL_GITHUB_API}/releases?per_page=100" \
    | jq -c 'select(.draft == false and .prerelease == false)'
}

# The commit sha a given tag currently points to (dereferenced), or empty.
resolve_tag_commit() {
  local tag="$1"

  github_api_get "${SPINEL_GITHUB_API}/tags?per_page=100" \
    | jq -r --arg tag "$tag" 'select(.name == $tag) | .commit.sha' \
    | head -n 1
}

version_ref() {
  local install_type="$1"
  local install_version="$2"

  case "$install_type" in
    version)
      case "$install_version" in
        master)
          printf 'master\n'
          ;;
        latest)
          local tag
          tag="$(latest_stable_version)"
          if [ "$tag" = "master" ]; then
            printf 'master\n'
          else
            version_ref version "$tag"
          fi
          ;;
        *)
          require_cmd curl
          require_cmd jq

          local sha
          sha="$(resolve_tag_commit "$install_version")"
          [ -n "$sha" ] || fail "unknown version '${install_version}'; run 'asdf list all ${TOOL_NAME}' to see available releases, or use 'master'/'ref:<git-ref>' to install an unreleased commit"
          printf '%s\n' "$sha"
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
  require_cmd curl
  require_cmd jq

  github_releases_json | jq -r '.tag_name' | sort -V
}

latest_stable_version() {
  require_cmd curl
  require_cmd jq

  local latest
  latest="$(list_versions | tail -n 1)"

  if [ -z "$latest" ]; then
    printf 'master\n'
  else
    printf '%s\n' "$latest"
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
