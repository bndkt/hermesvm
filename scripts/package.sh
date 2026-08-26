#!/usr/bin/env bash
# Write the Swift Package artifacts from a Hermes destroot.
# Usage: package.sh <destroot> <tag>
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
destroot="${1:?destroot}"
tag="${2:?tag}"
git_url="https://github.com/bndkt/hermesvm"

xcframework="${destroot}/Library/Frameworks/universal/hermesvm.xcframework"
hermesc_src="${destroot}/bin/hermesc"
include_src="${destroot}/include"

if [[ ! -d "${xcframework}" ]]; then
  echo "missing ${xcframework}" >&2
  exit 1
fi
if [[ ! -x "${hermesc_src}" ]]; then
  echo "missing ${hermesc_src}" >&2
  exit 1
fi

# C++ consumers include <hermes/hermes.h> and <jsi/jsi.h>. The first-party
# XCFramework has no Headers. Put destroot/include in each slice.
while IFS= read -r -d '' framework; do
  if [[ -d "${framework}/Versions" ]]; then
    mkdir -p "${framework}/Versions/1/Headers"
    cp -R "${include_src}/." "${framework}/Versions/1/Headers/"
    ln -sfn "Versions/Current/Headers" "${framework}/Headers"
  else
    mkdir -p "${framework}/Headers"
    cp -R "${include_src}/." "${framework}/Headers/"
  fi
done < <(find "${xcframework}" -name 'hermesvm.framework' -type d -print0)

dist="${root}/dist"
mkdir -p "${dist}"
zip_path="${dist}/hermesvm.xcframework.zip"
hermesc_dst="${dist}/hermesc"

rm -f "${zip_path}" "${hermesc_dst}"
(
  cd "$(dirname "${xcframework}")"
  zip -r -y -q "${zip_path}" "$(basename "${xcframework}")"
)
cp "${hermesc_src}" "${hermesc_dst}"
chmod +x "${hermesc_dst}"

checksum="$(sha256sum "${zip_path}" | awk '{print $1}')"

rm -rf "${root}/Sources/hermesvmHeaders"
rm -f "${root}/Sources/_hermesvmStub/empty.c"
mkdir -p "${root}/Sources/_hermesvmStub"
printf '%s\n' "enum _HermesvmStub {}" > "${root}/Sources/_hermesvmStub/empty.swift"

cat > "${root}/Package.swift" <<EOF
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "hermesvm",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(name: "hermesvm", targets: ["hermesvm", "_hermesvmStub"]),
    ],
    targets: [
        .binaryTarget(
            name: "hermesvm",
            url: "${git_url}/releases/download/${tag}/hermesvm.xcframework.zip",
            checksum: "${checksum}"
        ),
        // Without at least one regular (non-binary) target, Xcode does not
        // embed a binary XCFramework. The stub is Swift so SwiftPM does not
        // require Sources/_hermesvmStub/include. The stub must not depend on
        // the binary and must not publish C++ headers.
        // See swift-package-manager#6069.
        .target(
            name: "_hermesvmStub",
            path: "Sources/_hermesvmStub"
        ),
    ]
)
EOF

printf '%s\n' "${checksum}" > "${dist}/checksum"
echo "Wrote ${zip_path}"
echo "Wrote ${hermesc_dst}"
echo "checksum ${checksum}"
