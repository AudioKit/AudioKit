#!/bin/bash
if test `find . -name \*.pbxproj -exec grep -H /Users/ {} \;|tee /tmp/found|wc -l` -gt 0; then
	cat /tmp/found
	exit 1
fi
set -o pipefail

echo "Building AudioKit Frameworks"
cd Frameworks
#./build_frameworks.sh || exit 1
cd ..

echo "Running iOS Tests"
xcodebuild -scheme AudioKitTestSuite -project AudioKit/iOS/AudioKitTestSuite/AudioKitTestSuite.xcodeproj test -destination 'platform=iOS Simulator,name=iPhone 5s' | xcpretty -c || exit 3

echo "Building iOS HelloWorld"
xcodebuild -project Examples/iOS/HelloWorld/HelloWorld.xcodeproj -sdk iphonesimulator -scheme HelloWorld -arch x86_64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 4

echo "Building macOS HelloWorld"
#xcodebuild -project Examples/macOS/HelloWorld/HelloWorld.xcodeproj -scheme HelloWorld clean build  | xcpretty -c || exit 5

echo "Building tvOS HelloWorld"
#xcodebuild -project Examples/tvOS/HelloWorld/HelloWorld.xcodeproj -sdk appletvsimulator -scheme HelloWorld ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 6


echo "Building More Advanced Examples"

echo "Building iOS AnalogSynthX"
xcodebuild -project Examples/iOS/AnalogSynthX/AnalogSynthX.xcodeproj -sdk iphonesimulator -scheme AnalogSynthX -arch x86_64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 7

echo "Building iOS HelloObjectiveC"
xcodebuild -project Examples/iOS/HelloObjectiveC/HelloObjectiveC.xcodeproj -sdk iphonesimulator -scheme HelloObjectiveC -arch x86_64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 8

echo "Building iOS MicrophoneAnalysis"
xcodebuild -project Examples/iOS/MicrophoneAnalysis/MicrophoneAnalysis.xcodeproj -sdk iphonesimulator -scheme MicrophoneAnalysis -arch x86_64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 9

echo "Building iOS MidiMonitor"
xcodebuild -project Examples/iOS/MidiMonitor/MidiMonitor.xcodeproj -sdk iphonesimulator -scheme MidiMonitor -arch x86_64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 1-

echo "Building iOS RecorderDemo"
xcodebuild -project Examples/iOS/RecorderDemo/RecorderDemo.xcodeproj -sdk iphonesimulator -scheme RecorderDemo -arch x86_64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 10

echo "Building iOS SamplerDemo"
xcodebuild -project Examples/iOS/SamplerDemo/SamplerDemo.xcodeproj -sdk iphonesimulator -scheme SamplerDemo -arch x86_64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 11

echo "Building iOS SequencerDemo"
xcodebuild -project Examples/iOS/SequencerDemo/SequencerDemo.xcodeproj -sdk iphonesimulator -scheme SequencerDemo -arch x86_64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 12

echo "Building iOS SongProcessor"
xcodebuild -project Examples/iOS/SongProcessor/SongProcessor.xcodeproj -sdk iphonesimulator -scheme SongProcessor -arch x86_64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 13

echo "Building iOS SporthEditor"
xcodebuild -project Examples/iOS/SporthEditor/SporthEditor.xcodeproj -sdk iphonesimulator -scheme SporthEditor -arch x86_64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 14

echo "Building macOS MicrophoneAnalysis"
#xcodebuild -project Examples/macOS/MicrophoneAnalysis/MicrophoneAnalysis.xcodeproj -scheme MicrophoneAnalysis ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 15

echo "Building macOS MidiMonitor"
#xcodebuild -project Examples/macOS/MidiMonitor/MidiMonitor.xcodeproj -scheme MidiMonitor ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 16

echo "Building macOS SporthEditor"
#xcodebuild -project Examples/macOS/SporthEditor/SporthEditor.xcodeproj  -scheme SporthEditor ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 17

echo "Skipping AudioKitParticles - requires hardware"
#xcodebuild -project Examples/iOS/AudioKitParticles/AudioKitParticles.xcodeproj -sdk iphonesimulator -scheme AudioKitParticles ONLY_ACTIVE_ARCH=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 16

