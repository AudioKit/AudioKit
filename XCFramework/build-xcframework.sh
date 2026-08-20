#!/bin/bash

set -euo pipefail

fail() {
    printf 'error: %s\n' "$1" >&2
    exit 1
}

require_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        fail "required command not found: $1"
    fi
}

readonly SCRIPT_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
readonly SOURCE_ROOT="$(cd "${SCRIPT_DIRECTORY}/.." && pwd -P)"

if [[ "$#" -gt 1 ]]; then
    fail "usage: $0 [output-directory]"
fi

for required_command in git xcodebuild xcrun plutil lipo otool file shasum ditto; do
    require_command "${required_command}"
done

readonly PROJECT="${SCRIPT_DIRECTORY}/AudioKitFramework.xcodeproj"
readonly SCHEME="AudioKitFramework"
readonly FRAMEWORK_NAME="AudioKit"
readonly OUTPUT_CANDIDATE="${1:-${SOURCE_ROOT}/.build/xcframework-output}"

ios_deployment_target="${XCFRAMEWORK_IOS_DEPLOYMENT_TARGET:-}"
macos_deployment_target="${XCFRAMEWORK_MACOS_DEPLOYMENT_TARGET:-}"
macos_architectures="${XCFRAMEWORK_MACOS_ARCHITECTURES:-}"

if [[ -t 0 ]]; then
    if [[ -z "${ios_deployment_target}" ]]; then
        printf 'Minimum iOS deployment target [15.0]: '
        if IFS= read -r entered_ios_target && [[ -n "${entered_ios_target}" ]]; then
            ios_deployment_target="${entered_ios_target}"
        fi
    fi

    if [[ -z "${macos_deployment_target}" ]]; then
        printf 'Minimum macOS deployment target [12.0]: '
        if IFS= read -r entered_macos_target && [[ -n "${entered_macos_target}" ]]; then
            macos_deployment_target="${entered_macos_target}"
        fi
    fi

    if [[ -z "${macos_architectures}" ]]; then
        while true; do
            printf 'Include Intel Mac support? [y/N]: '
            if ! IFS= read -r include_intel; then
                break
            fi

            case "${include_intel}" in
                ""|n|N|no|No|NO)
                    macos_architectures="arm64"
                    break
                    ;;
                y|Y|yes|Yes|YES)
                    macos_architectures="arm64 x86_64"
                    break
                    ;;
                *)
                    printf 'Please answer y or n.\n' >&2
                    ;;
            esac
        done
    fi
fi

readonly MINIMUM_IOS_VERSION="${ios_deployment_target:-15.0}"
readonly MINIMUM_MACOS_VERSION="${macos_deployment_target:-12.0}"
readonly MACOS_ARCHITECTURES="${macos_architectures:-arm64}"

[[ "${MINIMUM_IOS_VERSION}" =~ ^[0-9]+(\.[0-9]+){1,2}$ ]] \
    || fail "invalid iOS deployment target: ${MINIMUM_IOS_VERSION}"
[[ "${MINIMUM_MACOS_VERSION}" =~ ^[0-9]+(\.[0-9]+){1,2}$ ]] \
    || fail "invalid macOS deployment target: ${MINIMUM_MACOS_VERSION}"

case "${MACOS_ARCHITECTURES}" in
    arm64)
        readonly MACOS_SLICE_IDENTIFIER="macos-arm64"
        ;;
    "arm64 x86_64")
        readonly MACOS_SLICE_IDENTIFIER="macos-arm64_x86_64"
        ;;
    *)
        fail "unsupported macOS architectures: ${MACOS_ARCHITECTURES}; use arm64 or arm64 x86_64"
        ;;
esac

[[ -f "${PROJECT}/project.pbxproj" ]] || fail "project not found: ${PROJECT}"
/bin/mkdir -p "${OUTPUT_CANDIDATE}"
readonly OUTPUT_DIRECTORY="$(cd "${OUTPUT_CANDIDATE}" && pwd -P)"

readonly SOURCE_COMMIT="$(/usr/bin/git -C "${SOURCE_ROOT}" rev-parse HEAD)"
readonly SOURCE_ORIGIN="$(/usr/bin/git -C "${SOURCE_ROOT}" remote get-url origin)"

upstream_tag="${AUDIOKIT_UPSTREAM_TAG:-$(/usr/bin/git -C "${SOURCE_ROOT}" describe --tags --abbrev=0 HEAD 2>/dev/null || true)}"
[[ -n "${upstream_tag}" ]] || fail "unable to determine the upstream release tag; set AUDIOKIT_UPSTREAM_TAG"
readonly UPSTREAM_TAG="${upstream_tag}"
readonly UPSTREAM_TAG_OBJECT="$(/usr/bin/git -C "${SOURCE_ROOT}" rev-parse "${UPSTREAM_TAG}")"
readonly UPSTREAM_COMMIT="$(/usr/bin/git -C "${SOURCE_ROOT}" rev-parse "${UPSTREAM_TAG}^{}")"

if ! /usr/bin/git -C "${SOURCE_ROOT}" merge-base --is-ancestor "${UPSTREAM_COMMIT}" HEAD; then
    fail "upstream tag ${UPSTREAM_TAG} is not an ancestor of HEAD"
fi

if ! /usr/bin/git -C "${SOURCE_ROOT}" diff --quiet "${UPSTREAM_TAG}" -- Package.swift Sources/AudioKit; then
    fail "Package.swift or Sources/AudioKit differ from upstream release ${UPSTREAM_TAG}"
fi

source_state="clean"
if [[ -n "$(/usr/bin/git -C "${SOURCE_ROOT}" status --porcelain --untracked-files=all)" ]]; then
    source_state="dirty development build"
fi
readonly SOURCE_STATE="${source_state}"

if [[ "${SOURCE_STATE}" != "clean" && "${ALLOW_DIRTY_BUILD:-0}" != "1" ]]; then
    fail "source repository is dirty; commit the build infrastructure or rerun with ALLOW_DIRTY_BUILD=1 for a non-publishable development artifact"
fi

if [[ "${SOURCE_STATE}" != "clean" ]]; then
    printf 'warning: building a non-publishable dirty development artifact\n' >&2
fi

readonly CACHE_ROOT="${SOURCE_ROOT}/.build/xcframework"
readonly DERIVED_DATA="${CACHE_ROOT}/DerivedData"
/bin/mkdir -p "${DERIVED_DATA}"

readonly WORK_ROOT="$(/usr/bin/mktemp -d /private/tmp/AudioKitXCFramework.XXXXXX)"
readonly DEVICE_ARCHIVE="${WORK_ROOT}/AudioKit-iOS.xcarchive"
readonly SIMULATOR_ARCHIVE="${WORK_ROOT}/AudioKit-Simulator.xcarchive"
readonly MACOS_ARCHIVE="${WORK_ROOT}/AudioKit-macOS.xcarchive"
readonly BUILT_XCFRAMEWORK="${WORK_ROOT}/AudioKit.xcframework"
readonly GENERATED_BUILD_INFO="${WORK_ROOT}/BUILD_INFO.md"
readonly SMOKE_SOURCE="${WORK_ROOT}/AudioKitBinarySmoke.swift"
readonly SMOKE_LIBRARY="${WORK_ROOT}/libAudioKitBinarySmoke.dylib"
readonly MACOS_ARM64_SMOKE_LIBRARY="${WORK_ROOT}/libAudioKitBinarySmoke-macOS-arm64.dylib"
readonly MACOS_X86_64_SMOKE_LIBRARY="${WORK_ROOT}/libAudioKitBinarySmoke-macOS-x86_64.dylib"
readonly DESTINATION_XCFRAMEWORK="${OUTPUT_DIRECTORY}/AudioKit.xcframework"
readonly INSTALL_STAGE="${OUTPUT_DIRECTORY}/.AudioKit.xcframework.new.$$"
readonly BUILD_INFO_STAGE="${OUTPUT_DIRECTORY}/.BUILD_INFO.md.new.$$"

BACKUP_XCFRAMEWORK=""
ACTIVE_BUILD_PID=""

readonly BUILD_STEP_COUNT=8

safe_remove() {
    local path="$1"

    case "${path}" in
        "${WORK_ROOT}"|"${OUTPUT_DIRECTORY}"/.AudioKit.xcframework.new.*|"${OUTPUT_DIRECTORY}"/.AudioKit.xcframework.previous.*|"${OUTPUT_DIRECTORY}"/.BUILD_INFO.md.new.*)
            if [[ -e "${path}" ]]; then
                /bin/rm -rf -- "${path}"
            fi
            ;;
        *)
            printf 'warning: refused to remove unexpected path %s\n' "${path}" >&2
            ;;
    esac
}

cleanup() {
    local status="$?"

    if [[ -n "${ACTIVE_BUILD_PID}" ]] && /bin/kill -0 "${ACTIVE_BUILD_PID}" 2>/dev/null; then
        /bin/kill "${ACTIVE_BUILD_PID}" 2>/dev/null || true
        wait "${ACTIVE_BUILD_PID}" 2>/dev/null || true
    fi

    if [[ -n "${BACKUP_XCFRAMEWORK}" && -e "${BACKUP_XCFRAMEWORK}" ]]; then
        if [[ ! -e "${DESTINATION_XCFRAMEWORK}" ]]; then
            /bin/mv "${BACKUP_XCFRAMEWORK}" "${DESTINATION_XCFRAMEWORK}"
        else
            safe_remove "${BACKUP_XCFRAMEWORK}"
        fi
    fi

    safe_remove "${INSTALL_STAGE}"
    safe_remove "${BUILD_INFO_STAGE}"
    safe_remove "${WORK_ROOT}"

    trap - EXIT
    exit "${status}"
}

trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

archive_framework() {
    local destination="$1"
    local archive_path="$2"
    local label="$3"
    local architectures="$4"
    local step_number="$5"
    local build_log="${WORK_ROOT}/${label// /-}.log"
    local started_at
    local current_time
    local build_status
    local spinner='|/-\'
    local spinner_index=0

    /usr/bin/xcodebuild archive \
        -project "${PROJECT}" \
        -scheme "${SCHEME}" \
        -configuration Release \
        -destination "${destination}" \
        -archivePath "${archive_path}" \
        -derivedDataPath "${DERIVED_DATA}" \
        CODE_SIGNING_ALLOWED=NO \
        SKIP_INSTALL=NO \
        BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
        ARCHS="${architectures}" \
        ONLY_ACTIVE_ARCH=NO \
        IPHONEOS_DEPLOYMENT_TARGET="${MINIMUM_IOS_VERSION}" \
        MACOSX_DEPLOYMENT_TARGET="${MINIMUM_MACOS_VERSION}" \
        DEBUG_INFORMATION_FORMAT=dwarf-with-dsym \
        >"${build_log}" 2>&1 &

    ACTIVE_BUILD_PID="$!"
    started_at="$(/bin/date +%s)"

    while /bin/kill -0 "${ACTIVE_BUILD_PID}" 2>/dev/null; do
        current_time="$(/bin/date +%s)"
        if [[ -t 1 ]]; then
            printf '\r\033[2K[%d/%d] %s %c %ss' \
                "${step_number}" "${BUILD_STEP_COUNT}" "${label}" "${spinner:spinner_index%4:1}" \
                "$((current_time - started_at))"

            spinner_index=$((spinner_index + 1))
        fi
        /bin/sleep 1
    done

    if wait "${ACTIVE_BUILD_PID}"; then
        build_status=0
    else
        build_status="$?"
    fi
    ACTIVE_BUILD_PID=""

    if [[ "${build_status}" -ne 0 ]]; then
        if [[ -t 1 ]]; then
            printf '\r\033[2K'
        fi
        printf '[%d/%d] %s failed. Last 200 build-log lines:\n' \
            "${step_number}" "${BUILD_STEP_COUNT}" "${label}" >&2
        /usr/bin/tail -n 200 "${build_log}" >&2
        fail "${label} failed with exit code ${build_status}"
    fi

    current_time="$(/bin/date +%s)"
    if [[ -t 1 ]]; then
        printf '\r\033[2K'
    fi
    printf '[%d/%d] %s finished in %ss.\n' \
        "${step_number}" "${BUILD_STEP_COUNT}" "${label}" "$((current_time - started_at))"
}

require_path() {
    [[ -e "$1" ]] || fail "expected build output is missing: $1"
}

uuid_list() {
    /usr/bin/xcrun dwarfdump --uuid "$1" \
        | /usr/bin/awk '{ print $2 " " $3 }' \
        | /usr/bin/sort
}

uuid_summary() {
    /usr/bin/xcrun dwarfdump --uuid "$1" \
        | /usr/bin/awk 'BEGIN { separator = "" } { printf "%s%s %s", separator, $2, $3; separator = ", " } END { print "" }'
}

assert_matching_uuids() {
    local binary="$1"
    local dsym="$2"
    local binary_uuids
    local dsym_uuids

    binary_uuids="$(uuid_list "${binary}")"
    dsym_uuids="$(uuid_list "${dsym}")"

    if [[ "${binary_uuids}" != "${dsym_uuids}" ]]; then
        printf 'Binary UUIDs:\n%s\n' "${binary_uuids}" >&2
        printf 'dSYM UUIDs:\n%s\n' "${dsym_uuids}" >&2
        fail "framework and dSYM UUIDs do not match"
    fi
}

assert_build_version() {
    local binary="$1"
    local expected_platform="$2"
    local expected_minimum="$3"
    local build_versions

    build_versions="$(/usr/bin/xcrun vtool -show-build "${binary}")"

    if ! /usr/bin/printf '%s\n' "${build_versions}" \
        | /usr/bin/grep -E -q "^[[:space:]]*platform ${expected_platform}$"; then
        fail "unexpected platform in binary: ${binary}"
    fi

    if ! /usr/bin/printf '%s\n' "${build_versions}" \
        | /usr/bin/grep -E -q "^[[:space:]]*minos ${expected_minimum}$"; then
        fail "unexpected minimum deployment target in binary: ${binary}"
    fi
}

assert_no_unexpected_runtime_dependency() {
    local binary="$1"
    local label="$2"

    if /usr/bin/otool -L "${binary}" \
        | /usr/bin/grep -v -E 'AudioKit.framework|/System/Library/Frameworks/|/usr/lib/|@rpath/libswift_[A-Za-z0-9_]+\.dylib' \
        | /usr/bin/grep -q .; then
        /usr/bin/otool -L "${binary}" >&2
        fail "${label} has an unexpected non-system runtime dependency"
    fi
}

printf '\nBuilding AudioKit %s.\n' "${UPSTREAM_TAG}"

archive_framework "generic/platform=iOS" "${DEVICE_ARCHIVE}" "iOS device" "arm64" 1

archive_framework "generic/platform=iOS Simulator" "${SIMULATOR_ARCHIVE}" "iOS Simulator" "arm64 x86_64" 2

archive_framework "generic/platform=macOS" "${MACOS_ARCHIVE}" "macOS" "${MACOS_ARCHITECTURES}" 3

readonly DEVICE_FRAMEWORK="${DEVICE_ARCHIVE}/Products/Library/Frameworks/AudioKit.framework"
readonly DEVICE_DSYM="${DEVICE_ARCHIVE}/dSYMs/AudioKit.framework.dSYM"
readonly SIMULATOR_FRAMEWORK="${SIMULATOR_ARCHIVE}/Products/Library/Frameworks/AudioKit.framework"
readonly SIMULATOR_DSYM="${SIMULATOR_ARCHIVE}/dSYMs/AudioKit.framework.dSYM"
readonly MACOS_FRAMEWORK="${MACOS_ARCHIVE}/Products/Library/Frameworks/AudioKit.framework"
readonly MACOS_DSYM="${MACOS_ARCHIVE}/dSYMs/AudioKit.framework.dSYM"

require_path "${DEVICE_FRAMEWORK}/AudioKit"
require_path "${DEVICE_DSYM}"
require_path "${SIMULATOR_FRAMEWORK}/AudioKit"
require_path "${SIMULATOR_DSYM}"
require_path "${MACOS_FRAMEWORK}/AudioKit"
require_path "${MACOS_DSYM}"

printf '[4/%d] Creating AudioKit.xcframework...\n' "${BUILD_STEP_COUNT}"
/usr/bin/xcodebuild -create-xcframework \
    -framework "${DEVICE_FRAMEWORK}" \
    -debug-symbols "${DEVICE_DSYM}" \
    -framework "${SIMULATOR_FRAMEWORK}" \
    -debug-symbols "${SIMULATOR_DSYM}" \
    -framework "${MACOS_FRAMEWORK}" \
    -debug-symbols "${MACOS_DSYM}" \
    -output "${BUILT_XCFRAMEWORK}"

readonly DEVICE_SLICE="${BUILT_XCFRAMEWORK}/ios-arm64"
readonly SIMULATOR_SLICE="${BUILT_XCFRAMEWORK}/ios-arm64_x86_64-simulator"
readonly MACOS_SLICE="${BUILT_XCFRAMEWORK}/${MACOS_SLICE_IDENTIFIER}"
readonly DEVICE_BINARY="${DEVICE_SLICE}/AudioKit.framework/AudioKit"
readonly DEVICE_XCFRAMEWORK_DSYM="${DEVICE_SLICE}/dSYMs/AudioKit.framework.dSYM"
readonly SIMULATOR_BINARY="${SIMULATOR_SLICE}/AudioKit.framework/AudioKit"
readonly SIMULATOR_XCFRAMEWORK_DSYM="${SIMULATOR_SLICE}/dSYMs/AudioKit.framework.dSYM"
readonly MACOS_BINARY="${MACOS_SLICE}/AudioKit.framework/Versions/A/AudioKit"
readonly MACOS_XCFRAMEWORK_DSYM="${MACOS_SLICE}/dSYMs/AudioKit.framework.dSYM"

require_path "${BUILT_XCFRAMEWORK}/Info.plist"
require_path "${DEVICE_BINARY}"
require_path "${DEVICE_XCFRAMEWORK_DSYM}"
require_path "${SIMULATOR_BINARY}"
require_path "${SIMULATOR_XCFRAMEWORK_DSYM}"
require_path "${MACOS_BINARY}"
require_path "${MACOS_XCFRAMEWORK_DSYM}"
require_path "${DEVICE_SLICE}/AudioKit.framework/PrivacyInfo.xcprivacy"
require_path "${SIMULATOR_SLICE}/AudioKit.framework/PrivacyInfo.xcprivacy"
require_path "${MACOS_SLICE}/AudioKit.framework/Versions/A/Resources/PrivacyInfo.xcprivacy"

printf '[5/%d] Validating slices, linkage, interfaces, resources, and dSYMs...\n' "${BUILD_STEP_COUNT}"
/usr/bin/plutil -lint "${BUILT_XCFRAMEWORK}/Info.plist" >/dev/null
/usr/bin/lipo "${DEVICE_BINARY}" -verify_arch arm64
/usr/bin/lipo "${SIMULATOR_BINARY}" -verify_arch arm64
/usr/bin/lipo "${SIMULATOR_BINARY}" -verify_arch x86_64
for macos_architecture in ${MACOS_ARCHITECTURES}; do
    /usr/bin/lipo "${MACOS_BINARY}" -verify_arch "${macos_architecture}"
done

if ! /usr/bin/file "${DEVICE_BINARY}" | /usr/bin/grep -q 'dynamically linked shared library'; then
    fail "device slice is not a dynamic framework"
fi

if ! /usr/bin/file "${SIMULATOR_BINARY}" | /usr/bin/grep -q 'dynamically linked shared library'; then
    fail "simulator slice is not a dynamic framework"
fi

if ! /usr/bin/file "${MACOS_BINARY}" | /usr/bin/grep -q 'dynamically linked shared library'; then
    fail "macOS slice is not a dynamic framework"
fi

assert_build_version "${DEVICE_BINARY}" IOS "${MINIMUM_IOS_VERSION}"
assert_build_version "${SIMULATOR_BINARY}" IOSSIMULATOR "${MINIMUM_IOS_VERSION}"
assert_build_version "${MACOS_BINARY}" MACOS "${MINIMUM_MACOS_VERSION}"

assert_no_unexpected_runtime_dependency "${DEVICE_BINARY}" "device slice"
assert_no_unexpected_runtime_dependency "${SIMULATOR_BINARY}" "simulator slice"
assert_no_unexpected_runtime_dependency "${MACOS_BINARY}" "macOS slice"

interface_count="$(/usr/bin/find "${BUILT_XCFRAMEWORK}" -type f -name '*.swiftinterface' | /usr/bin/wc -l | /usr/bin/tr -d ' ')"
[[ "${interface_count}" -ge 3 ]] || fail "stable Swift module interfaces are missing"

assert_matching_uuids "${DEVICE_BINARY}" "${DEVICE_XCFRAMEWORK_DSYM}"
assert_matching_uuids "${SIMULATOR_BINARY}" "${SIMULATOR_XCFRAMEWORK_DSYM}"
assert_matching_uuids "${MACOS_BINARY}" "${MACOS_XCFRAMEWORK_DSYM}"

printf '[6/%d] Linking a clean iOS Simulator smoke module against the binary only...\n' "${BUILD_STEP_COUNT}"
/usr/bin/printf '%s\n' \
    'import AudioKit' \
    '' \
    'public func makeBinarySmokeMixer() -> Mixer {' \
    '    Mixer(name: "AudioKit binary smoke")' \
    '}' \
    >"${SMOKE_SOURCE}"

readonly SIMULATOR_SDK="$(/usr/bin/xcrun --sdk iphonesimulator --show-sdk-path)"
/usr/bin/xcrun --sdk iphonesimulator swiftc \
    "${SMOKE_SOURCE}" \
    -parse-as-library \
    -emit-library \
    -target "arm64-apple-ios${MINIMUM_IOS_VERSION}-simulator" \
    -sdk "${SIMULATOR_SDK}" \
    -F "${SIMULATOR_SLICE}" \
    -framework AudioKit \
    -o "${SMOKE_LIBRARY}"
require_path "${SMOKE_LIBRARY}"

printf '[7/%d] Linking clean macOS smoke modules against the binary only...\n' "${BUILD_STEP_COUNT}"
readonly MACOS_SDK="$(/usr/bin/xcrun --sdk macosx --show-sdk-path)"
for macos_architecture in ${MACOS_ARCHITECTURES}; do
    if [[ "${macos_architecture}" == "arm64" ]]; then
        macos_smoke_library="${MACOS_ARM64_SMOKE_LIBRARY}"
    else
        macos_smoke_library="${MACOS_X86_64_SMOKE_LIBRARY}"
    fi

    /usr/bin/xcrun --sdk macosx swiftc \
        "${SMOKE_SOURCE}" \
        -parse-as-library \
        -emit-library \
        -target "${macos_architecture}-apple-macosx${MINIMUM_MACOS_VERSION}" \
        -sdk "${MACOS_SDK}" \
        -F "${MACOS_SLICE}" \
        -framework AudioKit \
        -o "${macos_smoke_library}"
    require_path "${macos_smoke_library}"
done

readonly BUILD_DATE="$(/bin/date '+%Y-%m-%d %H:%M:%S %Z')"
readonly XCODE_VERSION="$(/usr/bin/xcodebuild -version | /usr/bin/awk 'NR == 1 { name = $0 } NR == 2 { print name " (" $3 ")" }')"
readonly SWIFT_VERSION="$(/usr/bin/xcrun swift --version 2>&1 | /usr/bin/awk 'NR == 1 { sub(/^.*Apple Swift version/, "Apple Swift version"); print; exit }')"
readonly DEVICE_ARCHITECTURES="$(/usr/bin/lipo -archs "${DEVICE_BINARY}")"
readonly SIMULATOR_ARCHITECTURES="$(/usr/bin/lipo -archs "${SIMULATOR_BINARY}")"
readonly BUILT_MACOS_ARCHITECTURES="$(/usr/bin/lipo -archs "${MACOS_BINARY}")"
readonly DEVICE_UUIDS="$(uuid_summary "${DEVICE_BINARY}")"
readonly SIMULATOR_UUIDS="$(uuid_summary "${SIMULATOR_BINARY}")"
readonly MACOS_UUIDS="$(uuid_summary "${MACOS_BINARY}")"
readonly DEVICE_SHA256="$(/usr/bin/shasum -a 256 "${DEVICE_BINARY}" | /usr/bin/awk '{ print $1 }')"
readonly SIMULATOR_SHA256="$(/usr/bin/shasum -a 256 "${SIMULATOR_BINARY}" | /usr/bin/awk '{ print $1 }')"
readonly MACOS_SHA256="$(/usr/bin/shasum -a 256 "${MACOS_BINARY}" | /usr/bin/awk '{ print $1 }')"

{
    printf '# Build information\n\n'
    printf -- '- Artifact: `AudioKit.xcframework`\n'
    printf -- '- AudioKit release: `%s`\n' "${UPSTREAM_TAG}"
    printf -- '- Upstream tag object: `%s`\n' "${UPSTREAM_TAG_OBJECT}"
    printf -- '- Upstream source commit: `%s`\n' "${UPSTREAM_COMMIT}"
    printf -- '- Build-infrastructure commit: `%s`\n' "${SOURCE_COMMIT}"
    printf -- '- Source repository: `%s`\n' "${SOURCE_ORIGIN}"
    printf -- '- Source state: `%s`\n' "${SOURCE_STATE}"
    printf -- '- Built: `%s`\n' "${BUILD_DATE}"
    printf -- '- Xcode: `%s`\n' "${XCODE_VERSION}"
    printf -- '- Swift: `%s`\n' "${SWIFT_VERSION}"
    printf -- '- Configuration: `Release`\n'
    printf -- '- Library evolution: enabled\n'
    printf -- '- Minimum iOS: `%s`\n' "${MINIMUM_IOS_VERSION}"
    printf -- '- Minimum macOS: `%s`\n\n' "${MINIMUM_MACOS_VERSION}"
    printf '## Slices and dSYM UUIDs\n\n'
    printf -- '- iOS %s: `%s`\n' "${DEVICE_ARCHITECTURES}" "${DEVICE_UUIDS}"
    printf -- '- iOS Simulator %s: `%s`\n' "${SIMULATOR_ARCHITECTURES}" "${SIMULATOR_UUIDS}"
    printf -- '- macOS %s: `%s`\n\n' "${BUILT_MACOS_ARCHITECTURES}" "${MACOS_UUIDS}"
    printf '## Binary SHA-256\n\n'
    printf -- '- iOS %s: `%s`\n' "${DEVICE_ARCHITECTURES}" "${DEVICE_SHA256}"
    printf -- '- iOS Simulator %s: `%s`\n' "${SIMULATOR_ARCHITECTURES}" "${SIMULATOR_SHA256}"
    printf -- '- macOS %s: `%s`\n\n' "${BUILT_MACOS_ARCHITECTURES}" "${MACOS_SHA256}"
    printf 'All slices contain `PrivacyInfo.xcprivacy`, stable Swift interfaces, and matching dSYMs. '
    printf 'The smoke checks import `AudioKit`, create a `Mixer`, and link on iOS Simulator plus the selected macOS architectures without source dependencies.\n'
} >"${GENERATED_BUILD_INFO}"

if [[ -e "${INSTALL_STAGE}" || -e "${BUILD_INFO_STAGE}" ]]; then
    fail "temporary install path already exists in output directory"
fi

printf '[8/%d] Installing the verified artifact into %s...\n' "${BUILD_STEP_COUNT}" "${OUTPUT_DIRECTORY}"
/usr/bin/ditto "${BUILT_XCFRAMEWORK}" "${INSTALL_STAGE}"
/bin/cp "${GENERATED_BUILD_INFO}" "${BUILD_INFO_STAGE}"

if [[ -e "${DESTINATION_XCFRAMEWORK}" ]]; then
    BACKUP_XCFRAMEWORK="${OUTPUT_DIRECTORY}/.AudioKit.xcframework.previous.$$"
    /bin/mv "${DESTINATION_XCFRAMEWORK}" "${BACKUP_XCFRAMEWORK}"
fi

/bin/mv "${INSTALL_STAGE}" "${DESTINATION_XCFRAMEWORK}"
/bin/mv -f "${BUILD_INFO_STAGE}" "${OUTPUT_DIRECTORY}/BUILD_INFO.md"

if [[ -n "${BACKUP_XCFRAMEWORK}" && -e "${BACKUP_XCFRAMEWORK}" ]]; then
    safe_remove "${BACKUP_XCFRAMEWORK}"
    BACKUP_XCFRAMEWORK=""
fi

printf '\nAudioKit XCFramework is ready:\n%s\n' "${DESTINATION_XCFRAMEWORK}"
printf 'Device UUIDs: %s\n' "${DEVICE_UUIDS}"
printf 'Simulator UUIDs: %s\n' "${SIMULATOR_UUIDS}"
printf 'macOS UUIDs: %s\n' "${MACOS_UUIDS}"
