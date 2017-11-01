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

echo "Building iOS HelloWorld"
xcodebuild -project Examples/iOS/HelloWorld/HelloWorld.xcodeproj -sdk iphonesimulator -scheme HelloWorld -arch x86_64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 4

echo "Building macOS HelloWorld"
xcodebuild -project Examples/macOS/HelloWorld/HelloWorld.xcodeproj -scheme HelloWorld clean build | xcpretty -c || exit 5

echo "Skipping tvOS HelloWorld"
#xcodebuild -project Examples/tvOS/HelloWorld/HelloWorld.xcodeproj -sdk appletvsimulator -scheme HelloWorld ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 6


echo "Building More Advanced Examples"

echo "Building iOS AnalogSynthX"
cd Examples/iOS/AnalogSynthX; pod install; cd ../../..
xcodebuild -workspace Examples/iOS/AnalogSynthX/AnalogSynthX.xcworkspace -sdk iphonesimulator -scheme AnalogSynthX -arch x86_64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 6

echo "Building iOS AudioUnitManager"
xcodebuild -project Examples/iOS/AudioUnitManager/AudioUnitManager.xcodeproj -sdk iphonesimulator -scheme AudioUnitManager -arch x86_64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 7

echo "Building iOS Drums"
xcodebuild -project Examples/iOS/Drums/Drums.xcodeproj -sdk iphonesimulator -scheme Drums -arch x86_64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 8

echo "Building iOS HelloObjectiveC"
xcodebuild -project Examples/iOS/HelloObjectiveC/HelloObjectiveC.xcodeproj -sdk iphonesimulator -scheme HelloObjectiveC -arch x86_64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 9

echo "Building iOS MetronomeSamplerSync"
xcodebuild -project Examples/iOS/MetronomeSamplerSync/MetronomeSamplerSync.xcodeproj -sdk iphonesimulator -scheme MetronomeSamplerSync -arch x86_64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 11

echo "Building iOS MicrophoneAnalysis"
xcodebuild -project Examples/iOS/MicrophoneAnalysis/MicrophoneAnalysis.xcodeproj -sdk iphonesimulator -scheme MicrophoneAnalysis -arch x86_64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 12

echo "Building iOS MIDIUtility"
xcodebuild -project Examples/iOS/MIDIUtility/MIDIUtility.xcodeproj -sdk iphonesimulator -scheme MIDIUtility -arch x86_64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 13

echo "Building iOS Recorder"
xcodebuild -project Examples/iOS/Recorder/Recorder.xcodeproj -sdk iphonesimulator -scheme Recorder -arch x86_64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 14

echo "Building iOS SamplerDemo"
xcodebuild -project Examples/iOS/SamplerDemo/SamplerDemo.xcodeproj -sdk iphonesimulator -scheme SamplerDemo -arch x86_64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 15

echo "Building iOS SequencerDemo"
xcodebuild -project Examples/iOS/SequencerDemo/SequencerDemo.xcodeproj -sdk iphonesimulator -scheme SequencerDemo -arch x86_64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 16

echo "Building iOS SongProcessor"
xcodebuild -project Examples/iOS/SongProcessor/SongProcessor.xcodeproj -sdk iphonesimulator -scheme SongProcessor -arch x86_64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 17

echo "Building iOS SporthEditor"
xcodebuild -project Examples/iOS/SporthEditor/SporthEditor.xcodeproj -sdk iphonesimulator -scheme SporthEditor -arch x86_64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 18

echo "Building macOS AudioUnitManager"
xcodebuild -project Examples/macOS/AudioUnitManager/AudioUnitManager.xcodeproj -scheme AudioUnitManager	 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 19

echo "Building macOS MicrophoneAnalysis"
xcodebuild -project Examples/macOS/MicrophoneAnalysis/MicrophoneAnalysis.xcodeproj -scheme MicrophoneAnalysis ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 19

echo "Building macOS MIDIUtility"
xcodebuild -project Examples/macOS/MIDIUtility/MIDIUtility.xcodeproj -scheme MIDIUtility ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 20

echo "Building macOS RandomClips"
xcodebuild -project Examples/macOS/RandomClips/RandomClips.xcodeproj -scheme RandomClips ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 21

echo "Building macOS Recorder"
xcodebuild -project Examples/macOS/Recorder/Recorder.xcodeproj -scheme Recorder ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 22

echo "Building macOS SporthEditor"
xcodebuild -project Examples/macOS/SporthEditor/SporthEditor.xcodeproj -scheme SporthEditor ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 23

echo "Skipping Particles - requires hardware"
#xcodebuild -project Examples/iOS/Particles/AudioKitParticles.xcodeproj -sdk iphonesimulator -scheme AudioKitParticles ONLY_ACTIVE_ARCH=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 24

echo "Building iOS Sender Synth"
cd Examples/iOS/SenderSynth; pod install; cd ../../..
xcodebuild -workspace Examples/iOS/SenderSynth/SenderSynth.xcworkspace -sdk iphonesimulator -scheme SenderSynth -arch x86_64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 24

echo "Building iOS Filter Effects"
cd Examples/iOS/FilterEffects; pod install; cd ../../..
xcodebuild -workspace Examples/iOS/FilterEffects/FilterEffects.xcworkspace -sdk iphonesimulator -scheme FilterEffects -arch x86_64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 25

echo "Running iOS Unit Tests"
xcodebuild -scheme AudioKitTestSuite -project AudioKit/iOS/AudioKitTestSuite/AudioKitTestSuite.xcodeproj test -sdk iphonesimulator  -destination 'platform=iOS Simulator,name=iPhone 7,OS=11.1' | xcpretty -c || exit 100
