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


echo "Building More Advanced Examples"

echo "Building iOS AnalogSynthX"
xcodebuild -project Examples/iOS/AnalogSynthX/AnalogSynthX.xcodeproj -sdk iphonesimulator -scheme AnalogSynthX ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 7

echo "Building iOS HelloObjectiveC"
xcodebuild -project Examples/iOS/HelloObjectiveC/HelloObjectiveC.xcodeproj -sdk iphonesimulator -scheme HelloObjectiveC ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 7

echo "Building iOS MicrophoneAnalysis"
xcodebuild -project Examples/iOS/MicrophoneAnalysis/MicrophoneAnalysis.xcodeproj -sdk iphonesimulator -scheme MicrophoneAnalysis ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 8

echo "Building iOS MidiMonitor"
xcodebuild -project Examples/iOS/MidiMonitor/MidiMonitor.xcodeproj -sdk iphonesimulator -scheme MidiMonitor ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 9

echo "Building iOS MollyBChimes"
xcodebuild -project Examples/iOS/MollyBChimes/MollyBChimes.xcodeproj -sdk iphonesimulator -scheme MollyBChimes ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 10

echo "Building iOS Recorder"
xcodebuild -project Examples/iOS/Recorder/Recorder.xcodeproj -sdk iphonesimulator -scheme Recorder ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 11

echo "Building iOS SequencerTracks"
xcodebuild -project Examples/iOS/SequencerTracks/SequencerTracks.xcodeproj -sdk iphonesimulator -scheme SequencerTracks ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 12

echo "Building iOS SongProcessor"
xcodebuild -project Examples/iOS/SongProcessor/SongProcessor.xcodeproj -sdk iphonesimulator -scheme SongProcessor ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 13

echo "Building OSX MicrophoneAnalysis"
xcodebuild -project Examples/OSX/MicrophoneAnalysis/MicrophoneAnalysis.xcodeproj -scheme MicrophoneAnalysis ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 14

echo "Building OSX MidiMonitor"
xcodebuild -project Examples/OSX/MidiMonitor/MidiMonitor.xcodeproj -scheme MidiMonitor ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 15

echo "Skipping AudioKitParticles - requires hardware"
#xcodebuild -project Examples/iOS/AudioKitParticles/AudioKitParticles.xcodeproj -sdk iphonesimulator -scheme AudioKitParticles ONLY_ACTIVE_ARCH=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 7

