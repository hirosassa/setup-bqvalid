#!/usr/bin/env bash
#
# Resolve the bqvalid release asset name for a given runner OS and architecture.
#
# Usage: resolve_asset.sh <os> <arch>
#   <os>   : the value of runner.os   (Linux | macOS | Windows)
#   <arch> : the value of runner.arch (X86 | X64 | ARM | ARM64)
#
# Prints the asset file name to stdout on success.
# Prints an error to stderr and exits non-zero for unsupported combinations.
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "usage: resolve_asset.sh <os> <arch>" >&2
  exit 2
fi

os="$1"
arch="$2"

case "${os}/${arch}" in
  Linux/X64)     echo "bqvalid-x86_64-linux.tar.gz" ;;
  macOS/X64)     echo "bqvalid-x86_64-darwin.tar.gz" ;;
  macOS/ARM64)   echo "bqvalid-arm64-darwin.tar.gz" ;;
  Windows/X64)   echo "bqvalid-x86_64-windows.zip" ;;
  *)
    echo "error: unsupported platform: os=${os} arch=${arch}" >&2
    exit 1
    ;;
esac
