#!/bin/bash
#
# Building examples and unit tests on macOS
#
if test `find . -name \*.pbxproj -exec grep -H /Users/ {} \;|tee /tmp/found|wc -l` -gt 0; then
	echo "Found some absolute references to user directories in the projects. This should be fixed!"
	cat /tmp/found
	exit 1
fi
set -o pipefail

echo "Skipping iOS+Catalyst HelloWorld because it can be built with Catalina, it references the AudioKit project file which we don't want to have to build again"
#xcodebuild -project Examples/iOS/HelloWorld/HelloWorld.xcodeproj -sdk iphonesimulator -scheme HelloWorld -arch x86_64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 4

echo "Skipping iOS+Catalyst Drums"
#xcodebuild -project Examples/iOS+Catalyst/Drums/Drums.xcodeproj -sdk iphonesimulator -scheme Drums -arch x86_64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 12

echo "Building macOS AudioUnitManager"
xcodebuild -project Examples/macOS/AudioUnitManager/AudioUnitManager.xcodeproj -scheme AudioUnitManager ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 22

echo "Building macOS FileConverter"
xcodebuild -project Examples/macOS/FileConverter/FileConverter.xcodeproj -scheme FileConverter ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 23

echo "Building macOS FlangerAndChorus"
xcodebuild -project Examples/macOS/FlangerAndChorus/FlangerAndChorus.xcodeproj -scheme FlangerAndChorus ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 24

echo "Building macOS MicrophoneAnalysis"
xcodebuild -project Examples/macOS/MicrophoneAnalysis/MicrophoneAnalysis.xcodeproj -scheme MicrophoneAnalysis ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 25

echo "Building macOS MIDIUtility"
xcodebuild -project Examples/macOS/MIDIUtility/MIDIUtility.xcodeproj -scheme MIDIUtility ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 26

echo "Building macOS RandomClips"
xcodebuild -project Examples/macOS/RandomClips/RandomClips.xcodeproj -scheme RandomClips ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 27

echo "Building macOS Recorder"
xcodebuild -project Examples/macOS/Recorder/Recorder.xcodeproj -scheme Recorder ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 28

echo "Building macOS SimpleAudioUnit"
xcodebuild -project Examples/macOS/SimpleAudioUnit/SimpleAudioUnit.xcodeproj -scheme SimpleAudioUnit ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 29

echo "Building macOS SpeechSynthesizer"
xcodebuild -project Examples/macOS/SpeechSynthesizer/SpeechSynthesizer.xcodeproj -scheme SpeechSynthesizer ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 29

echo "Running macOS Unit Tests"
xcodebuild -project Tests/macOSTestSuite/macOSTestSuite.xcodeproj -scheme macOSTestSuite test ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" | xcpretty -c || exit 101
