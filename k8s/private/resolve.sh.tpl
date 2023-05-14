#!/usr/bin/env bash
set -o pipefail -o errexit -o nounset

readonly YQ="{{yq_path}}"

# set $@ to be FIXED_ARGS+$@
ALL_ARGS=(${FIXED_ARGS[@]} $@)
set -- ${ALL_ARGS[@]}

INPUT=""
OUTPUT=""

IMAGES=()

for ARG in "$@"; do
    case "$ARG" in
        (--input=*) INPUT="${ARG#--input=}";;
        (--output=*) OUTPUT="${ARG#--output=}";;
        (--image=*) IMAGES+=( "${ARG#--image=}" );;
        (*) echo "Unknown argument ${ARG}"; exit 1;;
    esac
done

cat "$INPUT" > "$OUTPUT"

for image in "${IMAGES[@]+"${IMAGES[@]}"}"; do
    DETAILS=(${image//;/ })
    REGISTRY=${DETAILS[0]} REPOSITORY=${DETAILS[1]} "${YQ}" -i '(. | select(.spec.template.spec.containers |= map( select(.image == strenv(REPOSITORY)).image |= sub("^", strenv(REGISTRY) + "/")))' $OUTPUT
done
