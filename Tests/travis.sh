#!/bin/bash
if test `find . -name \*.pbxproj -exec grep -H /Users/ {} \;|tee /tmp/found|wc -l` -gt 0; then
	cat /tmp/found
	exit 1
fi
set -o pipefail

echo "Building AudioKit Frameworks"
cd Frameworks
./build_frameworks.sh || exit 1
cd ..

echo "Building OSX HelloWorld"
xcodebuild -project Examples/OSX/HelloWorld/HelloWorld.xcodeproj -scheme HelloWorld clean build  | xcpretty -c || exit 4

echo "Building iOS HelloWorld"
xcodebuild -project Examples/iOS/HelloWorld/HelloWorld.xcodeproj -sdk iphonesimulator -scheme HelloWorld ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 5

echo "Building tvOS HelloWorld"
xcodebuild -project Examples/tvOS/HelloWorld/HelloWorld.xcodeproj -sdk appletvsimulator -scheme HelloWorld ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 6

#echo "Building AudioKitParticles"
#xcodebuild -project Examples/iOS/AudioKitParticles/AudioKitParticles.xcodeproj -sdk iphonesimulator -scheme AudioKitParticles ONLY_ACTIVE_ARCH=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 7

