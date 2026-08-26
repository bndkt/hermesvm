#!/usr/bin/env bash
# Check the Swift Package artifacts at the public seams.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=pin.env
source "${root}/pin.env"

zip_path="${root}/dist/hermesvm.xcframework.zip"
hermesc="${root}/dist/hermesc"
manifest="${root}/Package.swift"
checksum_file="${root}/dist/checksum"

test -f "${zip_path}"
test -x "${hermesc}"
test -f "${manifest}"
test -f "${checksum_file}"

checksum="$(cat "${checksum_file}")"
actual="$(sha256sum "${zip_path}" | awk '{print $1}')"
test "${checksum}" = "${actual}"

grep -q "${checksum}" "${manifest}"
grep -q "binaryTarget" "${manifest}"
grep -q "_hermesvmStub" "${manifest}"
grep -q "hermesvm.xcframework.zip" "${manifest}"
grep -q "releases/download/${HERMESVM_TAG}/" "${manifest}"
if grep -q "hermesvmHeaders" "${manifest}"; then
  echo "Package.swift must not declare hermesvmHeaders" >&2
  exit 1
fi

list="$(unzip -Z1 "${zip_path}")"
printf '%s\n' "${list}" | grep -qx "hermesvm.xcframework/Info.plist"
printf '%s\n' "${list}" | grep -q "hermesvm.xcframework/ios-arm64/hermesvm.framework/hermesvm"
printf '%s\n' "${list}" | grep -q "hermesvm.xcframework/ios-arm64_x86_64-simulator/hermesvm.framework/hermesvm"
printf '%s\n' "${list}" | grep -q "hermesvm.xcframework/ios-arm64/hermesvm.framework/Headers/hermes/hermes.h"
printf '%s\n' "${list}" | grep -q "hermesvm.xcframework/ios-arm64/hermesvm.framework/Headers/jsi/jsi.h"

test -f "${root}/Sources/_hermesvmStub/empty.c"

file "${hermesc}" | grep -q "Mach-O"

echo "hermesvm artifacts match the Swift Package seams"
