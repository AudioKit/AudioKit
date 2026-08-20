#!/bin/zsh

set -u

readonly COMMAND_DIRECTORY="${0:A:h}"
readonly SOURCE_ROOT="${COMMAND_DIRECTORY:h}"
readonly BUILD_SCRIPT="${COMMAND_DIRECTORY}/build-xcframework.sh"

if [[ -n "${AUDIOKIT_XCFRAMEWORK_OUTPUT:-}" ]]; then
    output_directory="${AUDIOKIT_XCFRAMEWORK_OUTPUT}"
elif [[ -d "${SOURCE_ROOT}/../AudioKitBinary" ]]; then
    output_directory="${SOURCE_ROOT}/../AudioKitBinary"
else
    output_directory="${SOURCE_ROOT}/.build/xcframework-output"
fi

readonly OUTPUT_DIRECTORY="${output_directory}"
clear
printf 'AudioKit XCFramework builder\n\n'
printf 'Output directory:\n%s\n\n' "${OUTPUT_DIRECTORY}"

if [[ ! -x "${BUILD_SCRIPT}" ]]; then
    printf 'Error: build script was not found or is not executable:\n%s\n' "${BUILD_SCRIPT}" >&2
    build_status=1
else
    "${BUILD_SCRIPT}" "${OUTPUT_DIRECTORY}"
    build_status="$?"
fi

if [[ "${build_status}" -eq 0 ]]; then
    printf '\nDone. AudioKit.xcframework was built successfully.\n'
else
    printf '\nThe build failed with exit code %s.\n' "${build_status}" >&2
fi

printf '\nPress Return to close this window...'
read -r

exit "${build_status}"
