#!/bin/bash
#
# Building examples and unit tests on iOS
#
if test `find . -name \*.pbxproj -exec grep -H /Users/ {} \;|tee /tmp/found|wc -l` -gt 0; then
	echo "Found some absolute references to user directories in the projects. This should be fixed!"
	cat /tmp/found
	exit 1
fi
set -o pipefail

DESTINATION='platform=iOS Simulator,name=iPhone 11,OS=13.6'
echo "Running iOS Unit Tests"
xcodebuild -scheme iOSTestSuite -project Tests/iOSTestSuite/iOSTestSuite.xcodeproj test -sdk iphonesimulator  -destination "$DESTINATION" | xcpretty -c || exit 100

echo "Building iOS AppleSamplerDemo"
xcodebuild -project Examples/iOS/AppleSamplerDemo/SamplerDemo.xcodeproj -sdk iphonesimulator -scheme SamplerDemo -arch x86_64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 9

echo "Building iOS AudioUnitManager"
xcodebuild -project Examples/iOS/AudioUnitManager/AudioUnitManager.xcodeproj -sdk iphonesimulator -scheme AudioUnitManager -arch x86_64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 1

echo "Building iOS MicrophoneAnalysis"
xcodebuild -project Examples/iOS/MicrophoneAnalysis/MicrophoneAnalysis.xcodeproj -sdk iphonesimulator -scheme MicrophoneAnalysis -arch x86_64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 15

echo "Building iOS MIDIFileEditAndSync"
xcodebuild -project Examples/iOS/MIDIFileEditAndSync/MIDIFileEditAndSync.xcodeproj -sdk iphonesimulator -scheme MIDIFileEditAndSync -arch x86_64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 16

echo "Building iOS MIDIUtility"
xcodebuild -project Examples/iOS/MIDIUtility/MIDIUtility.xcodeproj -sdk iphonesimulator -scheme MIDIUtility -arch x86_64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 16

echo "Building iOS Recorder"
xcodebuild -project Examples/iOS/Recorder/Recorder.xcodeproj -sdk iphonesimulator -scheme Recorder -arch x86_64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 17
