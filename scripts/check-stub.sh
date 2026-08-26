#!/usr/bin/env bash
# Fail when the hermesvm stub would make Xcode report:
# public headers ("include") directory path for '_hermesvmStub' is invalid
#
# SwiftPM C-family targets default publicHeadersPath to "include" relative
# to the target path. A missing include/ is that error. A Swift stub does
# not need include/.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
stub="${root}/Sources/_hermesvmStub"

if [[ ! -d "${stub}" ]]; then
  echo "missing ${stub}" >&2
  exit 1
fi

mapfile -t c_family < <(find "${stub}" \( -name '*.c' -o -name '*.m' -o -name '*.mm' -o -name '*.cpp' \) | sort)
if ((${#c_family[@]} > 0)) && [[ ! -d "${stub}/include" ]]; then
  printf 'public headers include directory missing for _hermesvmStub\n' >&2
  printf '%s\n' "${c_family[@]}" >&2
  exit 1
fi

test -f "${stub}/empty.swift"
if [[ -f "${stub}/empty.c" ]]; then
  echo "stub must be Swift, not C" >&2
  exit 1
fi
