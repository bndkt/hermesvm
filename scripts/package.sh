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

headers="${root}/Sources/hermesvmHeaders/include"
rm -rf "${headers}"
mkdir -p "${headers}"
cp -R "${include_src}/." "${headers}/"
mkdir -p "${root}/Sources/hermesvmHeaders"
printf '%s\n' "/* Header target for hermesvm. */" > "${root}/Sources/hermesvmHeaders/empty.c"

cat > "${root}/Package.swift" <<EOF
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "hermesvm",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(name: "hermesvm", targets: ["hermesvm", "hermesvmHeaders"]),
    ],
    targets: [
        .binaryTarget(
            name: "hermesvm",
            url: "${git_url}/releases/download/${tag}/hermesvm.xcframework.zip",
            checksum: "${checksum}"
        ),
        .target(
            name: "hermesvmHeaders",
            dependencies: ["hermesvm"],
            path: "Sources/hermesvmHeaders",
            publicHeadersPath: "include"
        ),
    ]
)
EOF

printf '%s\n' "${checksum}" > "${dist}/checksum"
echo "Wrote ${zip_path}"
echo "Wrote ${hermesc_dst}"
echo "checksum ${checksum}"
