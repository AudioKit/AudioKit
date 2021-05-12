#!/bin/bash
#
# Create an XCFramework from the other built frameworks for all platforms
#
set -o pipefail

BUILD_DIR="$PWD/build"
CONFIGURATION=${CONFIGURATION:-"Release"}
DESTINATION=${1:-"."}

create_xcframework()
{
	echo "Assembling xcframework for $1 ..."
	rm -rf ${DESTINATION}/$1.xcframework # Start fresh
	BASIC_OPTS="-framework ${BUILD_DIR}/${CONFIGURATION}-iphonesimulator/$1.framework \
		-framework ${BUILD_DIR}/${CONFIGURATION}-appletvsimulator/$1.framework \
		-framework ${BUILD_DIR}/${CONFIGURATION}/$1.framework \
        -framework ${BUILD_DIR}/Catalyst.xcarchive/Products/Library/Frameworks/$1.framework"

	DEVICE_OPTS="-framework ${BUILD_DIR}/${CONFIGURATION}-iphoneos/$1.framework \
		-framework ${BUILD_DIR}/${CONFIGURATION}-appletvos/$1.framework"

	xcodebuild -create-xcframework -output ${DESTINATION}/$1.xcframework $BASIC_OPTS $DEVICE_OPTS
}

for f in AudioKit $(cat Frameworks.list); do
	create_xcframework $f
done
