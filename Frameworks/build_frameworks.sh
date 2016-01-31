#!/bin/bash
#
# Build AudioKit universal frameworks suited for distribution.
#
set -o pipefail

PROJECT_NAME=AudioKit
CONFIGURATION=Release
BUILD_DIR="$PWD/build"
VERSION=`cat ../VERSION`
PLATFORMS=${PLATFORMS:-"iOS OSX tvOS"}

if which xcpretty > /dev/null 2>&1;
then
	XCPRETTY=xcpretty
else
	XCPRETTY=cat
fi

create_universal_framework()
{
	PROJECT="../AudioKit/$1/AudioKit For $1.xcodeproj"
	DIR="AudioKit-$1"
	OUTPUT="$DIR/${PROJECT_NAME}.framework"
	rm -rf "$OUTPUT"
	mkdir -p "$DIR"
	xcodebuild -project "$PROJECT" -target "${PROJECT_NAME}" -xcconfig device.xcconfig -configuration ${CONFIGURATION} -sdk $2 BUILD_DIR="${BUILD_DIR}" clean build | $XCPRETTY || exit 2
	cp -av "${BUILD_DIR}/${CONFIGURATION}-$2/${PROJECT_NAME}.framework" "$OUTPUT"
	cp -av "${BUILD_DIR}/${CONFIGURATION}-$2/${PROJECT_NAME}.framework.dSYM" "$DIR"
	cp -v fix-framework.sh "$OUTPUT/"
	mkdir -p "$OUTPUT/BCSymbolMaps"
	cp -av "${BUILD_DIR}/${CONFIGURATION}-$2"/*.bcsymbolmap "$OUTPUT/BCSymbolMaps/"
	xcodebuild -project "$PROJECT" -target "${PROJECT_NAME}" -xcconfig simulator.xcconfig -configuration ${CONFIGURATION} -sdk $3 BUILD_DIR="${BUILD_DIR}" clean build | $XCPRETTY || exit 3
	cp -v "${BUILD_DIR}/${CONFIGURATION}-$3/${PROJECT_NAME}.framework/Modules/${PROJECT_NAME}.swiftmodule/"* "${OUTPUT}/Modules/${PROJECT_NAME}.swiftmodule/"
	lipo -create -output "${OUTPUT}/${PROJECT_NAME}" "${BUILD_DIR}/${CONFIGURATION}-$2/${PROJECT_NAME}.framework/${PROJECT_NAME}" "${BUILD_DIR}/${CONFIGURATION}-$3/${PROJECT_NAME}.framework/${PROJECT_NAME}" || exit 4
	lipo -create -output "${OUTPUT}.dSYM/Contents/Resources/DWARF/${PROJECT_NAME}" "${BUILD_DIR}/${CONFIGURATION}-$2/${PROJECT_NAME}.framework.dSYM/Contents/Resources/DWARF/${PROJECT_NAME}" "${BUILD_DIR}/${CONFIGURATION}-$3/${PROJECT_NAME}.framework.dSYM/Contents/Resources/DWARF/${PROJECT_NAME}" || exit 5
}

create_osx_framework()
{
	PROJECT="../AudioKit/$1/AudioKit For $1.xcodeproj"
	DIR="AudioKit-$1"
	OUTPUT="$DIR/${PROJECT_NAME}.framework"
	rm -rf "$OUTPUT"
	mkdir -p "$DIR"
	xcodebuild -project "$PROJECT" -target "${PROJECT_NAME}" ONLY_ACTIVE_ARCH=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" -configuration ${CONFIGURATION} -sdk $2 BUILD_DIR="${BUILD_DIR}" clean build | $XCPRETTY
	cp -av "${BUILD_DIR}/${CONFIGURATION}/${PROJECT_NAME}.framework" "$OUTPUT"
	cp -av "${BUILD_DIR}/${CONFIGURATION}/${PROJECT_NAME}.framework.dSYM" "$OUTPUT"
}

echo "Building frameworks for platforms: $PLATFORMS"

for os in $PLATFORMS; do
	if test $os = 'iOS'; then
		create_universal_framework iOS iphoneos iphonesimulator
	elif test $os = 'tvOS'; then
		create_universal_framework tvOS appletvos appletvsimulator
	elif test $os = 'OSX'; then
		create_osx_framework OSX macosx
	fi
done
