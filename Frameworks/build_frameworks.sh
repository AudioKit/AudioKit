#!/bin/bash
#
# Build AudioKit universal frameworks suited for distribution.
#
set -o pipefail

PROJECT_NAME=AudioKit
CONFIGURATION=Release
BUILD_DIR="$PWD/build"
VERSION=`cat ../VERSION`
PLATFORMS=${PLATFORMS:-"iOS macOS tvOS"}

if test "$TRAVIS" = true;
then
	echo "Travis detected, build #$TRAVIS_BUILD_NUMBER"
	ACTIVE_ARCH=YES
	XCSUFFIX="-travis"
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
	PROJECT="../AudioKit/$1/AudioKit for $1.xcodeproj"
	DIR="AudioKit-$1"
	OUTPUT="$DIR/${PROJECT_NAME}.framework"
	rm -rf "$OUTPUT"
	mkdir -p "$DIR"
	xcodebuild -project "$PROJECT" -target "${PROJECT_NAME}" -xcconfig simulator${XCSUFFIX}.xcconfig -configuration ${CONFIGURATION} -sdk $2 BUILD_DIR="${BUILD_DIR}" clean build | $XCPRETTY || exit 2
	cp -av "${BUILD_DIR}/${CONFIGURATION}-$2/${PROJECT_NAME}.framework" "$OUTPUT"
	cp -av "${BUILD_DIR}/${CONFIGURATION}-$2/${PROJECT_NAME}.framework.dSYM" "$DIR"
	cp -v fix-framework.sh "${OUTPUT}/"
	if test "$TRAVIS" = true;
	then # Only build for simulator on Travis CI
		cp -v "${BUILD_DIR}/${CONFIGURATION}-$2/${PROJECT_NAME}.framework/${PROJECT_NAME}" "${OUTPUT}/${PROJECT_NAME}"
		cp -v "${BUILD_DIR}/${CONFIGURATION}-$2/${PROJECT_NAME}.framework/Modules/${PROJECT_NAME}.swiftmodule/"* "${OUTPUT}/Modules/${PROJECT_NAME}.swiftmodule/"
	else # Build device slices
		xcodebuild -project "$PROJECT" -target "${PROJECT_NAME}" -xcconfig device.xcconfig -configuration ${CONFIGURATION} -sdk $3 BUILD_DIR="${BUILD_DIR}" clean build | $XCPRETTY || exit 3
		cp -v "${BUILD_DIR}/${CONFIGURATION}-$3/${PROJECT_NAME}.framework/Modules/${PROJECT_NAME}.swiftmodule/"* "${OUTPUT}/Modules/${PROJECT_NAME}.swiftmodule/"
		cp -v "${BUILD_DIR}/${CONFIGURATION}-$3/${PROJECT_NAME}.framework/Info.plist" "${OUTPUT}/"
		mkdir -p "${OUTPUT}/BCSymbolMaps"
		cp -av "${BUILD_DIR}/${CONFIGURATION}-$3"/*.bcsymbolmap "$OUTPUT/BCSymbolMaps/"
		lipo -create -output "${OUTPUT}/${PROJECT_NAME}" "${BUILD_DIR}/${CONFIGURATION}-$2/${PROJECT_NAME}.framework/${PROJECT_NAME}" "${BUILD_DIR}/${CONFIGURATION}-$3/${PROJECT_NAME}.framework/${PROJECT_NAME}" || exit 4
		lipo -create -output "${OUTPUT}.dSYM/Contents/Resources/DWARF/${PROJECT_NAME}" "${BUILD_DIR}/${CONFIGURATION}-$2/${PROJECT_NAME}.framework.dSYM/Contents/Resources/DWARF/${PROJECT_NAME}" "${BUILD_DIR}/${CONFIGURATION}-$3/${PROJECT_NAME}.framework.dSYM/Contents/Resources/DWARF/${PROJECT_NAME}" || exit 5
	fi
}

create_macos_framework()
{
	PROJECT="../AudioKit/$1/AudioKit For $1.xcodeproj"
	DIR="AudioKit-$1"
	OUTPUT="$DIR/${PROJECT_NAME}.framework"
	rm -rf "$OUTPUT"
	mkdir -p "$DIR"
	xcodebuild -project "$PROJECT" -target "${PROJECT_NAME}" ONLY_ACTIVE_ARCH=$ACTIVE_ARCH CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" -configuration ${CONFIGURATION} -sdk $2 BUILD_DIR="${BUILD_DIR}" clean build | $XCPRETTY || exit 2
	cp -av "${BUILD_DIR}/${CONFIGURATION}/${PROJECT_NAME}.framework" "$OUTPUT"
	cp -av "${BUILD_DIR}/${CONFIGURATION}/${PROJECT_NAME}.framework.dSYM" "$DIR"
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
