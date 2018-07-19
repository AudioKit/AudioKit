#!/bin/bash
#
# Build AudioKit universal frameworks suited for distribution.
#
set -o pipefail

PROJECT_NAME=AudioKit
PROJECT_UI_NAME=AudioKitUI
CONFIGURATION=${CONFIGURATION:-"Release"}
STAGING_BRANCH="staging"
BUILD_DIR="$PWD/build"

if [ ! -f build_frameworks.sh ]; then
    echo "This script needs to be run from the Frameworks folder"
    exit 0
fi

VERSION=`cat ../VERSION`
PLATFORMS=${PLATFORMS:-"iOS macOS tvOS"}

if test "$TRAVIS" = true && test "$TRAVIS_TAG" = "" && test "$TRAVIS_BRANCH" != "$STAGING_BRANCH";
then
	echo "Travis detected, build #$TRAVIS_BUILD_NUMBER"
	ACTIVE_ARCH=YES
	XCSUFFIX="-travis"
	PLATFORMS="iOS macOS" # Skipping tvOS?
else
	ACTIVE_ARCH=NO
	XCSUFFIX=""
fi

if which xcpretty > /dev/null 2>&1;
then
	XCPRETTY=xcpretty
else
	XCPRETTY=cat
fi

# Provide 3 arguments: platform (iOS or tvOS), simulator os, native os
create_universal_framework()
{
	PROJECT="../AudioKit/$1/AudioKit For $1.xcodeproj"
	DIR="AudioKit-$1"
	rm -rf "$DIR/$PROJECT_NAME.framework" "$DIR/$PROJECT_UI_NAME.framework"
	mkdir -p "$DIR"
	xcodebuild -project "$PROJECT" -target $PROJECT_UI_NAME -xcconfig simulator${XCSUFFIX}.xcconfig -configuration ${CONFIGURATION} -sdk $2 BUILD_DIR="${BUILD_DIR}" clean build | $XCPRETTY || exit 2
	if test -d  "${BUILD_DIR}/${CONFIGURATION}-$2/${PROJECT_NAME}.framework.dSYM"; then
		DYNAMIC=true
	fi
	cp -av "${BUILD_DIR}/${CONFIGURATION}-$2/${PROJECT_NAME}.framework" "${BUILD_DIR}/${CONFIGURATION}-$2/${PROJECT_UI_NAME}.framework" "$DIR/"
	if test "$DYNAMIC" = true;
	then
		cp -av "${BUILD_DIR}/${CONFIGURATION}-$2/${PROJECT_NAME}.framework.dSYM" "${BUILD_DIR}/${CONFIGURATION}-$2/${PROJECT_UI_NAME}.framework.dSYM" "$DIR/"
		cp -v fix-framework.sh "${DIR}/${PROJECT_NAME}.framework/"
	fi
	
	if test "$TRAVIS" = true && test "$TRAVIS_TAG" = "" && test "$TRAVIS_BRANCH" != "$STAGING_BRANCH";
	then # Only build for simulator on Travis CI, unless we're building a release
		cp -v "${BUILD_DIR}/${CONFIGURATION}-$2/${PROJECT_NAME}.framework/${PROJECT_NAME}" "${DIR}/${PROJECT_NAME}.framework/"
		cp -v "${BUILD_DIR}/${CONFIGURATION}-$2/${PROJECT_UI_NAME}.framework/${PROJECT_UI_NAME}" "${DIR}/${PROJECT_UI_NAME}.framework/"
		cp -v "${BUILD_DIR}/${CONFIGURATION}-$2/${PROJECT_NAME}.framework/Modules/${PROJECT_NAME}.swiftmodule/"* "${DIR}/${PROJECT_NAME}.framework/Modules/${PROJECT_NAME}.swiftmodule/"
		cp -v "${BUILD_DIR}/${CONFIGURATION}-$2/${PROJECT_UI_NAME}.framework/Modules/${PROJECT_UI_NAME}.swiftmodule/"* "${DIR}/${PROJECT_UI_NAME}.framework/Modules/${PROJECT_UI_NAME}.swiftmodule/"
	else # Build device slices
		xcodebuild -project "$PROJECT" -target "${PROJECT_UI_NAME}" -xcconfig device.xcconfig -configuration ${CONFIGURATION} -sdk $3 BUILD_DIR="${BUILD_DIR}" clean build | $XCPRETTY || exit 3
		cp -v "${BUILD_DIR}/${CONFIGURATION}-$3/${PROJECT_NAME}.framework/Modules/${PROJECT_NAME}.swiftmodule/"* \
			"${DIR}/${PROJECT_NAME}.framework/Modules/${PROJECT_NAME}.swiftmodule/"
		cp -v "${BUILD_DIR}/${CONFIGURATION}-$3/${PROJECT_UI_NAME}.framework/Modules/${PROJECT_UI_NAME}.swiftmodule/"* \
			"${DIR}/${PROJECT_UI_NAME}.framework/Modules/${PROJECT_UI_NAME}.swiftmodule/"
		cp -v "${BUILD_DIR}/${CONFIGURATION}-$3/${PROJECT_NAME}.framework/Info.plist" "${DIR}/${PROJECT_NAME}.framework/"
		cp -v "${BUILD_DIR}/${CONFIGURATION}-$3/${PROJECT_UI_NAME}.framework/Info.plist" "${DIR}/${PROJECT_UI_NAME}.framework/"
		# Merge the frameworks proper
		lipo -create -output "${DIR}/${PROJECT_NAME}.framework/${PROJECT_NAME}" \
			"${BUILD_DIR}/${CONFIGURATION}-$2/${PROJECT_NAME}.framework/${PROJECT_NAME}" \
			"${BUILD_DIR}/${CONFIGURATION}-$3/${PROJECT_NAME}.framework/${PROJECT_NAME}" || exit 4
		lipo -create -output "${DIR}/${PROJECT_UI_NAME}.framework/${PROJECT_UI_NAME}" \
			"${BUILD_DIR}/${CONFIGURATION}-$2/${PROJECT_UI_NAME}.framework/${PROJECT_UI_NAME}" \
			"${BUILD_DIR}/${CONFIGURATION}-$3/${PROJECT_UI_NAME}.framework/${PROJECT_UI_NAME}" || exit 4
		if test "$DYNAMIC" = true;
		then
			mkdir -p "${DIR}/${PROJECT_NAME}.framework/BCSymbolMaps" "${DIR}/${PROJECT_UI_NAME}.framework/BCSymbolMaps"
			# Doesn't seem to have a way to tell which bcsymbolmap belogs to which framework
			cp -av "${BUILD_DIR}/${CONFIGURATION}-$3"/*.bcsymbolmap "${DIR}/${PROJECT_NAME}.framework/BCSymbolMaps/"
			UIBC=`fgrep -Hn AudioKitUI "${BUILD_DIR}/${CONFIGURATION}-$3"/*.bcsymbolmap|awk -F: '{print $1}'|uniq`
			cp -av $UIBC "${DIR}/${PROJECT_UI_NAME}.framework/BCSymbolMaps/"
			# Merge the dSYM files
			lipo -create -output "${DIR}/${PROJECT_NAME}.framework.dSYM/Contents/Resources/DWARF/${PROJECT_NAME}" \
				"${BUILD_DIR}/${CONFIGURATION}-$2/${PROJECT_NAME}.framework.dSYM/Contents/Resources/DWARF/${PROJECT_NAME}" \
				"${BUILD_DIR}/${CONFIGURATION}-$3/${PROJECT_NAME}.framework.dSYM/Contents/Resources/DWARF/${PROJECT_NAME}" || exit 5
			lipo -create -output "${DIR}/${PROJECT_UI_NAME}.framework.dSYM/Contents/Resources/DWARF/${PROJECT_UI_NAME}" \
				"${BUILD_DIR}/${CONFIGURATION}-$2/${PROJECT_UI_NAME}.framework.dSYM/Contents/Resources/DWARF/${PROJECT_UI_NAME}" \
				"${BUILD_DIR}/${CONFIGURATION}-$3/${PROJECT_UI_NAME}.framework.dSYM/Contents/Resources/DWARF/${PROJECT_UI_NAME}" || exit 5
		else # Strip debug symbols from static library
			strip -S "${DIR}/${PROJECT_NAME}.framework/${PROJECT_NAME}" "${DIR}/${PROJECT_UI_NAME}.framework/${PROJECT_UI_NAME}"
		fi
	fi
}

# Provide 2 arguments: platform (macOS), native os (macosx)
create_macos_framework()
{
	PROJECT="../AudioKit/$1/AudioKit For $1.xcodeproj"
	DIR="AudioKit-$1"
	rm -rf "${DIR}/${PROJECT_NAME}.framework" "${DIR}/${PROJECT_UI_NAME}.framework"
	mkdir -p "$DIR"
	xcodebuild -project "$PROJECT" -target $PROJECT_UI_NAME ONLY_ACTIVE_ARCH=$ACTIVE_ARCH CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" -configuration ${CONFIGURATION} -sdk $2 BUILD_DIR="${BUILD_DIR}" clean build | $XCPRETTY || exit 2
	cp -av "${BUILD_DIR}/${CONFIGURATION}/${PROJECT_NAME}.framework" "${BUILD_DIR}/${CONFIGURATION}/${PROJECT_UI_NAME}.framework" "$DIR/"
	if test -d  "${BUILD_DIR}/${CONFIGURATION}/${PROJECT_NAME}.framework.dSYM";
	then
		cp -av "${BUILD_DIR}/${CONFIGURATION}/${PROJECT_NAME}.framework.dSYM" "${BUILD_DIR}/${CONFIGURATION}/${PROJECT_UI_NAME}.framework.dSYM" "$DIR/"
	else
		strip -S "${DIR}/${PROJECT_NAME}.framework/${PROJECT_NAME}" "${DIR}/${PROJECT_UI_NAME}.framework/${PROJECT_UI_NAME}"
	fi
}

echo "Building frameworks for platforms: $PLATFORMS"

for os in $PLATFORMS; do
	if test $os = 'iOS'; then
		create_universal_framework iOS iphonesimulator iphoneos
	elif test $os = 'tvOS'; then
		create_universal_framework tvOS appletvsimulator appletvos
	elif test $os = 'macOS'; then
		create_macos_framework macOS macosx
	fi
done

