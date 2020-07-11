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

echo "Building iOS AppleSamplerDemo"
xcodebuild -project Examples/iOS/AppleSamplerDemo/SamplerDemo.xcodeproj -sdk iphonesimulator -scheme SamplerDemo -arch x86_64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 9

echo "Building iOS AudioUnitManager"
xcodebuild -project Examples/iOS/AudioUnitManager/AudioUnitManager.xcodeproj -sdk iphonesimulator -scheme AudioUnitManager -arch x86_64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 1

echo "Building iOS LoopbackRecording"
xcodebuild -project Examples/iOS/LoopbackRecording/LoopbackRecording.xcodeproj -sdk iphonesimulator -scheme LoopbackRecording -arch x86_64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 14

echo "Building iOS MetronomeSamplerSync"
xcodebuild -project Examples/iOS/MetronomeSamplerSync/MetronomeSamplerSync.xcodeproj -sdk iphonesimulator -scheme MetronomeSamplerSync -arch x86_64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 14

echo "Building iOS MicrophoneAnalysis"
xcodebuild -project Examples/iOS/MicrophoneAnalysis/MicrophoneAnalysis.xcodeproj -sdk iphonesimulator -scheme MicrophoneAnalysis -arch x86_64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 15

echo "Building iOS MIDIFileEditAndSync"
xcodebuild -project Examples/iOS/MIDIFileEditAndSync/MIDIFileEditAndSync.xcodeproj -sdk iphonesimulator -scheme MIDIFileEditAndSync -arch x86_64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 16

echo "Building iOS MIDIUtility"
xcodebuild -project Examples/iOS/MIDIUtility/MIDIUtility.xcodeproj -sdk iphonesimulator -scheme MIDIUtility -arch x86_64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 16

echo "Building iOS Recorder"
xcodebuild -project Examples/iOS/Recorder/Recorder.xcodeproj -sdk iphonesimulator -scheme Recorder -arch x86_64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 17

echo "Building iOS SequencerDemo"
xcodebuild -project Examples/iOS/SequencerDemo/SequencerDemo.xcodeproj -sdk iphonesimulator -scheme SequencerDemo -arch x86_64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 18

echo "Building iOS AudiobusMIDISender"
cd Examples/iOS/AudiobusMIDISender; pod install; cd ../../..
xcodebuild -workspace Examples/iOS/AudiobusMIDISender/AudiobusMIDISender.xcworkspace -sdk iphonesimulator -scheme AudiobusMIDISender -arch x86_64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 31

echo "Building iOS Sender Synth"
cd Examples/iOS/SenderSynth; pod install; cd ../../..
xcodebuild -workspace Examples/iOS/SenderSynth/SenderSynth.xcworkspace -sdk iphonesimulator -scheme SenderSynth -arch x86_64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 32

echo "Building iOS Filter Effects"
cd Examples/iOS/FilterEffects; pod install; cd ../../..
xcodebuild -workspace Examples/iOS/FilterEffects/FilterEffects.xcworkspace -sdk iphonesimulator -scheme FilterEffects -arch x86_64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 33

echo "Running iOS Unit Tests"
xcodebuild -scheme iOSTestSuite -project Tests/iOSTestSuite/iOSTestSuite.xcodeproj test -sdk iphonesimulator  -destination 'platform=iOS Simulator,name=iPhone 11,OS=13.5' | xcpretty -c || exit 100
