#!/usr/bin/env bash
set -o pipefail -o errexit -o nounset

# A wrapper for kubectl. 

readonly KUBECTL="{{kubectl_path}}"

OPTIONS="{{options}}"

"${KUBECTL}" {{command}} "${OPTIONS}"
