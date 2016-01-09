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
	DIR="AudioKit-$1-$VERSION"
	OUTPUT="$DIR/${PROJECT_NAME}.framework"
	rm -rf "$OUTPUT"
	mkdir -p "$DIR"
	ln -sf "$DIR" "AudioKit-$1"
	xcodebuild -project "$PROJECT" -target "${PROJECT_NAME}" ONLY_ACTIVE_ARCH=NO -configuration ${CONFIGURATION} -sdk $2 BUILD_DIR="${BUILD_DIR}" clean build | $XCPRETTY
	cp -a "${BUILD_DIR}/${CONFIGURATION}-$2/${PROJECT_NAME}.framework" "$OUTPUT"
	xcodebuild -project "$PROJECT" -target "${PROJECT_NAME}" ONLY_ACTIVE_ARCH=NO -configuration ${CONFIGURATION} -sdk $3 BUILD_DIR="${BUILD_DIR}" clean build | $XCPRETTY
	lipo -create -output "${OUTPUT}/${PROJECT_NAME}" "${BUILD_DIR}/${CONFIGURATION}-$2/${PROJECT_NAME}.framework/${PROJECT_NAME}" "${BUILD_DIR}/${CONFIGURATION}-$3/${PROJECT_NAME}.framework/${PROJECT_NAME}"
}

create_osx_framework()
{
	PROJECT="../AudioKit/$1/AudioKit For $1.xcodeproj"
	DIR="AudioKit-$1-$VERSION"
	OUTPUT="$DIR/${PROJECT_NAME}.framework"
	rm -rf "$OUTPUT"
	mkdir -p "$DIR"
	ln -sf "$DIR" "AudioKit-$1"
	xcodebuild -project "$PROJECT" -target "${PROJECT_NAME}" ONLY_ACTIVE_ARCH=NO -configuration ${CONFIGURATION} -sdk $2 BUILD_DIR="${BUILD_DIR}" clean build | $XCPRETTY
	cp -a "${BUILD_DIR}/${CONFIGURATION}/${PROJECT_NAME}.framework" "$OUTPUT"
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
