#!/bin/bash
#
# Building examples and unit tests on macOS
#
set -o pipefail

echo "Building iOS+Catalyst HelloWorld"
xcodebuild -project Examples/iOS+Catalyst/HelloWorld/HelloWorld.xcodeproj -scheme HelloWorld -arch x86_64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 4

echo "Building iOS+Catalyst Drums"
xcodebuild -project Examples/iOS+Catalyst/Drums/Drums.xcodeproj -scheme Drums -arch x86_64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 12

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
