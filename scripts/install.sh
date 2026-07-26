#!/usr/bin/env bash
#
# Download and install a bqvalid release, then expose it on PATH.
#
# Required environment variables:
#   INPUT_VERSION  : requested version ("latest", "0.3.0" or "v0.3.0")
#   RUNNER_OS      : runner.os   (Linux | macOS | Windows)
#   RUNNER_ARCH    : runner.arch (X86 | X64 | ARM | ARM64)
#   RUNNER_TEMP    : a writable temp directory provided by the runner
#   GITHUB_PATH    : file to which additional PATH entries are appended
#   GITHUB_OUTPUT  : file to which step outputs are written
# Optional:
#   GITHUB_TOKEN   : token used to raise the GitHub API rate limit
set -euo pipefail

REPO="hirosassa/bqvalid"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

: "${INPUT_VERSION:?INPUT_VERSION is required}"
: "${RUNNER_OS:?RUNNER_OS is required}"
: "${RUNNER_ARCH:?RUNNER_ARCH is required}"
: "${RUNNER_TEMP:?RUNNER_TEMP is required}"

# Resolve the release tag (e.g. "v0.3.0") from the requested version.
resolve_tag() {
  local version="$1"
  if [[ "$version" == "latest" ]]; then
    local api="https://api.github.com/repos/${REPO}/releases/latest"
    local auth=()
    if [[ -n "${GITHUB_TOKEN:-}" ]]; then
      auth=(-H "Authorization: Bearer ${GITHUB_TOKEN}")
    fi
    local tag
    tag="$(curl -fsSL "${auth[@]+"${auth[@]}"}" "$api" \
      | grep -m1 '"tag_name":' \
      | sed -E 's/.*"tag_name": *"([^"]+)".*/\1/')"
    if [[ -z "$tag" ]]; then
      echo "error: could not resolve the latest release tag" >&2
      return 1
    fi
    echo "$tag"
  elif [[ "$version" == v* ]]; then
    echo "$version"
  else
    echo "v${version}"
  fi
}

tag="$(resolve_tag "$INPUT_VERSION")"
asset="$("${SCRIPT_DIR}/resolve_asset.sh" "$RUNNER_OS" "$RUNNER_ARCH")"
url="https://github.com/${REPO}/releases/download/${tag}/${asset}"

install_dir="${RUNNER_TEMP}/setup-bqvalid"
bin_dir="${install_dir}/bin"
download_dir="${install_dir}/download"
rm -rf "$install_dir"
mkdir -p "$bin_dir" "$download_dir"

echo "Downloading bqvalid ${tag} from ${url}"
archive="${download_dir}/${asset}"
curl -fsSL -o "$archive" "$url"

case "$asset" in
  *.tar.gz) tar -xzf "$archive" -C "$download_dir" ;;
  *.zip)
    if command -v unzip >/dev/null 2>&1; then
      unzip -q "$archive" -d "$download_dir"
    elif command -v 7z >/dev/null 2>&1; then
      7z x -y -o"$download_dir" "$archive" >/dev/null
    else
      echo "error: neither unzip nor 7z is available to extract ${asset}" >&2
      exit 1
    fi
    ;;
  *)
    echo "error: unknown archive type: ${asset}" >&2
    exit 1
    ;;
esac

bin_name="bqvalid"
if [[ "$RUNNER_OS" == "Windows" ]]; then
  bin_name="bqvalid.exe"
fi

if [[ ! -f "${download_dir}/${bin_name}" ]]; then
  echo "error: ${bin_name} not found in the extracted archive" >&2
  exit 1
fi

mv "${download_dir}/${bin_name}" "${bin_dir}/${bin_name}"
chmod +x "${bin_dir}/${bin_name}"

# Expose the binary on PATH for subsequent steps.
echo "$bin_dir" >>"$GITHUB_PATH"

# Verify the installation works.
resolved_version="$("${bin_dir}/${bin_name}" --version)"
echo "Installed ${resolved_version}"

# Emit the resolved tag (without the leading "v") as a step output.
echo "version=${tag#v}" >>"$GITHUB_OUTPUT"
