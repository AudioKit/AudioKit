#!/bin/bash
#
# Building examples and unit tests on tvOS
#
set -o pipefail

echo "Building tvOS HelloWorld"
xcodebuild -project Examples/tvOS/HelloWorld/HelloWorld.xcodeproj -sdk appletvsimulator -scheme HelloWorld ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 6
