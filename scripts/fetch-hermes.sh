#!/usr/bin/env bash
# Fetch the pinned Hermes iOS destroot. Compiler and VM stay in that destroot.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=pin.env
source "${root}/pin.env"

cache="${root}/dist/cache"
mkdir -p "${cache}"
tarball="${cache}/hermes-ios-${HERMES_IOS_VERSION}-hermes-ios-release.tar.gz"

if [[ ! -f "${tarball}" ]]; then
  echo "Fetching ${HERMES_IOS_TARBALL_URL}" >&2
  curl -L --fail -o "${tarball}" "${HERMES_IOS_TARBALL_URL}"
fi

extract="${root}/dist/extract"
rm -rf "${extract}"
mkdir -p "${extract}"
tar -xzf "${tarball}" -C "${extract}"

if [[ -d "${extract}/destroot" ]]; then
  dest="${extract}/destroot"
else
  dest="${extract}"
fi

xcframework="${dest}/Library/Frameworks/universal/hermesvm.xcframework"
hermesc="${dest}/bin/hermesc"
include="${dest}/include"

if [[ ! -d "${xcframework}" ]]; then
  echo "hermesvm.xcframework is missing after extract" >&2
  exit 1
fi
if [[ ! -x "${hermesc}" ]]; then
  echo "macOS hermesc is missing after extract" >&2
  exit 1
fi
if [[ ! -d "${include}/hermes" || ! -d "${include}/jsi" ]]; then
  echo "Hermes headers are missing after extract" >&2
  exit 1
fi

printf '%s\n' "${dest}"
