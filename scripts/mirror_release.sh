#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

VERSION=v1.27.1

declare -A assets
assets["darwin-arm64"]=https://dl.k8s.io/release/$VERSION/bin/darwin/arm64/kubectl
assets["darwin-amd64"]=https://dl.k8s.io/release/$VERSION/bin/darwin/amd64/kubectl
assets["linux-arm64"]=https://dl.k8s.io/release/$VERSION/bin/linux/arm64/kubectl
assets["linux-amd64"]=https://dl.k8s.io/release/$VERSION/bin/linux/amd64/kubectl
assets["windows-arm64"]=https://dl.k8s.io/release/$VERSION/bin/windows/arm64/kubectl.exe
assets["windows-amd64"]=https://dl.k8s.io/release/$VERSION/bin/windows/amd64/kubectl.exe

echo -n "TOOL_VERSIONS = {"
echo ""
echo "    \"$VERSION\": {"
for platform in ${!assets[@]}; do
    echo "        \"${platform}\": \"sha384-$(curl -sSL ${assets[${platform}]} | shasum -b -a 384 | awk "{ print \$1 }" | xxd -r -p | base64)\","
done
echo "    },"
echo "}"

echo
echo "Now, paste the above output into swc/private/versions.bzl"
