#!/bin/bash
#
# Build AudioKit universal frameworks suited for distribution.
#
set -o pipefail

PROJECT_NAME=AudioKit
PROJECT_UI_NAME=AudioKitUI
CONFIGURATION=Release
BUILD_DIR="$PWD/build"
VERSION=`cat ../VERSION`
PLATFORMS=${PLATFORMS:-"macOS iOS tvOS"}

if test "$TRAVIS" = true;
then
	echo "Travis detected, build #$TRAVIS_BUILD_NUMBER"
	ACTIVE_ARCH=YES
	XCSUFFIX="-travis"
	PLATFORMS="macOS iOS" # Skipping tvOS?
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

# Provide 5 arguments: platform (iOS or tvOS), simulator os, native os, framework name, additional command
create_universal_framework()
{
	PROJECT="../AudioKit/$1/AudioKit For $1.xcodeproj"
	DIR="AudioKit-$1"
	OUTPUT="$DIR/${4}.framework"
	rm -rf "$OUTPUT"
	mkdir -p "$DIR"
	xcodebuild -project "$PROJECT" -target "${4}" -xcconfig simulator${XCSUFFIX}.xcconfig -configuration ${CONFIGURATION} -sdk $2 BUILD_DIR="${BUILD_DIR}" $5 build | $XCPRETTY || exit 2
	cp -av "${BUILD_DIR}/${CONFIGURATION}-$2/${4}.framework" "$OUTPUT"
	cp -av "${BUILD_DIR}/${CONFIGURATION}-$2/${4}.framework.dSYM" "$DIR"
	cp -v fix-framework.sh "${OUTPUT}/"
	if test "$TRAVIS" = true;
	then # Only build for simulator on Travis CI
		cp -v "${BUILD_DIR}/${CONFIGURATION}-$2/${4}.framework/${4}" "${OUTPUT}/${4}"
		cp -v "${BUILD_DIR}/${CONFIGURATION}-$2/${4}.framework/Modules/${4}.swiftmodule/"* "${OUTPUT}/Modules/${4}.swiftmodule/"
	else # Build device slices
		xcodebuild -project "$PROJECT" -target "${4}" -xcconfig device.xcconfig -configuration ${CONFIGURATION} -sdk $3 BUILD_DIR="${BUILD_DIR}" $5 build | $XCPRETTY || exit 3
		cp -v "${BUILD_DIR}/${CONFIGURATION}-$3/${4}.framework/Modules/${4}.swiftmodule/"* "${OUTPUT}/Modules/${4}.swiftmodule/"
		cp -v "${BUILD_DIR}/${CONFIGURATION}-$3/${4}.framework/Info.plist" "${OUTPUT}/"
		mkdir -p "${OUTPUT}/BCSymbolMaps"
		cp -av "${BUILD_DIR}/${CONFIGURATION}-$3"/*.bcsymbolmap "$OUTPUT/BCSymbolMaps/"
		lipo -create -output "${OUTPUT}/${4}" "${BUILD_DIR}/${CONFIGURATION}-$2/${4}.framework/${4}" "${BUILD_DIR}/${CONFIGURATION}-$3/${4}.framework/${4}" || exit 4
		lipo -create -output "${OUTPUT}.dSYM/Contents/Resources/DWARF/${4}" "${BUILD_DIR}/${CONFIGURATION}-$2/${4}.framework.dSYM/Contents/Resources/DWARF/${4}" "${BUILD_DIR}/${CONFIGURATION}-$3/${4}.framework.dSYM/Contents/Resources/DWARF/${4}" || exit 5
	fi
}

# Provide 4 arguments: platform (macOS), native os (macosx), framework name, additional command
create_macos_framework()
{
	PROJECT="../AudioKit/$1/AudioKit For $1.xcodeproj"
	DIR="AudioKit-$1"
	OUTPUT="$DIR/${3}.framework"
	rm -rf "$OUTPUT"
	mkdir -p "$DIR"
	xcodebuild -project "$PROJECT" -target "${3}" ONLY_ACTIVE_ARCH=$ACTIVE_ARCH CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" -configuration ${CONFIGURATION} -sdk $2 BUILD_DIR="${BUILD_DIR}" $4 build | $XCPRETTY || exit 2
	cp -av "${BUILD_DIR}/${CONFIGURATION}/${3}.framework" "$OUTPUT"
	cp -av "${BUILD_DIR}/${CONFIGURATION}/${3}.framework.dSYM" "$DIR"
}

echo "Building frameworks for platforms: $PLATFORMS"

for os in $PLATFORMS; do
	if test $os = 'iOS'; then
		create_universal_framework iOS iphonesimulator iphoneos $PROJECT_NAME clean
		create_universal_framework iOS iphonesimulator iphoneos $PROJECT_UI_NAME
	elif test $os = 'tvOS'; then
		create_universal_framework tvOS appletvsimulator appletvos $PROJECT_NAME clean
		create_universal_framework tvOS appletvsimulator appletvos $PROJECT_UI_NAME
	elif test $os = 'macOS'; then
		create_macos_framework macOS macosx $PROJECT_NAME clean
		create_macos_framework macOS macosx $PROJECT_UI_NAME
	fi
done
