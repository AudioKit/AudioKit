#!/bin/bash
if test `find . -name \*.pbxproj -exec grep -H /Users/ {} \;|tee /tmp/found|wc -l` -gt 0; then
	cat /tmp/found
	exit 1
fi
set -o pipefail

echo "Building AudioKit For OSX"
xcodebuild -project AudioKit/OSX/AudioKit\ For\ OSX.xcodeproj | xcpretty -c || exit 1

echo "Building AudioKit For iOS"
xcodebuild -project AudioKit/iOS/AudioKit\ For\ iOS.xcodeproj | xcpretty -c || exit 2

echo "Building AudioKit For tvOS"
xcodebuild -project AudioKit/tvOS/AudioKit\ For\ tvOS.xcodeproj | xcpretty -c || exit 3

echo "Building OSX HelloWorld"
xcodebuild -project Examples/OSX/HelloWorld/HelloWorld.xcodeproj -scheme HelloWorld build  | xcpretty -c || exit 4

echo "Building iOS HelloWorld"
xcodebuild -project Examples/iOS/HelloWorld/HelloWorld.xcodeproj  -scheme HelloWorld ONLY_ACTIVE_ARCH=NO build | xcpretty -c || exit 5

echo "tvOS HelloWorld not built in this test due to code signing issues"
# xcodebuild -project Examples/tvOS/HelloWorld/HelloWorld.xcodeproj -scheme HelloWorld ONLY_ACTIVE_ARCH=NO build | xcpretty -c || exit 6

echo "Building AudioKitParticles"
xcodebuild -project Examples/iOS/AudioKitParticles/AudioKitParticles.xcodeproj -scheme AudioKitParticles ONLY_ACTIVE_ARCH=NO build | xcpretty -c || exit 7

