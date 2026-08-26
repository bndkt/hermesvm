#!/usr/bin/env bash
# Fetch the pin, write the Swift Package, and print the Release assets.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=pin.env
source "${root}/pin.env"

destroot="$("${root}/scripts/fetch-hermes.sh")"
"${root}/scripts/package.sh" "${destroot}" "${HERMESVM_TAG}"
"${root}/scripts/check.sh"
