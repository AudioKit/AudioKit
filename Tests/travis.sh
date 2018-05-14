#!/bin/bash
if test `find . -name \*.pbxproj -exec grep -H /Users/ {} \;|tee /tmp/found|wc -l` -gt 0; then
	echo "Found some absolute references to user directories in the projects. This should be fixed!"
	cat /tmp/found
	exit 1
fi
set -o pipefail

VERSION=$(cat VERSION)

echo "Building AudioKit Frameworks"
cd Frameworks
if test "$TRAVIS_TAG" != "" || test "$TRAVIS_BRANCH" = "staging"; then
   if test "$AWS_ACCESS_KEY" = ""; then
      echo "You must set the AWS_ACCESS_KEY and AWS_SECRET environment variables in Travis for automated builds!" >&2
      exit 1
   fi
   if test "$TRAVIS_TAG" != ""; then
   	echo "Deploying for release tagged $TRAVIS_TAG ..."
   else
   	echo "Deploying staging release build for v$VERSION..."
   fi
   ./build_packages.sh || exit 1
   echo "Uploading CocoaPods archive to S3 ..."
   if test "$TRAVIS_TAG" != ""; then
   	s3cmd --access_key=$AWS_ACCESS_KEY --secret_key=$AWS_SECRET put packages/AudioKit.framework.zip s3://files.audiokit.io/releases/${TRAVIS_TAG}/AudioKit.framework.zip
   else
   	s3cmd --access_key=$AWS_ACCESS_KEY --secret_key=$AWS_SECRET put packages/AudioKit.framework.zip s3://files.audiokit.io/staging/v${VERSION}/AudioKit.framework.zip
   fi
   exit
else
   ./build_frameworks.sh || exit 1
fi
cd ..

echo "Building iOS HelloWorld"
xcodebuild -project Examples/iOS/HelloWorld/HelloWorld.xcodeproj -sdk iphonesimulator -scheme HelloWorld -arch x86_64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 4

echo "Building macOS HelloWorld"
xcodebuild -project Examples/macOS/HelloWorld/HelloWorld.xcodeproj -scheme HelloWorld clean build | xcpretty -c || exit 5

echo "Skipping tvOS HelloWorld (on develop branch)"
#xcodebuild -project Examples/tvOS/HelloWorld/HelloWorld.xcodeproj -sdk appletvsimulator -scheme HelloWorld ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 6

echo "Building More Advanced Examples"

echo "Building iOS AKSamplerDemo"
xcodebuild -project Examples/iOS/AKSamplerDemo/AKSamplerDemo.xcodeproj -sdk iphonesimulator -scheme AKSamplerDemo -arch x86_64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 8

echo "Building iOS AppleSamplerDemo"
xcodebuild -project Examples/iOS/AppleSamplerDemo/SamplerDemo.xcodeproj -sdk iphonesimulator -scheme SamplerDemo -arch x86_64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 9

echo "Building iOS AudioUnitManager"
xcodebuild -project Examples/iOS/AudioUnitManager/AudioUnitManager.xcodeproj -sdk iphonesimulator -scheme AudioUnitManager -arch x86_64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 1

echo "Building iOS Drums"
xcodebuild -project Examples/iOS/Drums/Drums.xcodeproj -sdk iphonesimulator -scheme Drums -arch x86_64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 12

echo "Building iOS HelloObjectiveC"
xcodebuild -project Examples/iOS/HelloObjectiveC/HelloObjectiveC.xcodeproj -sdk iphonesimulator -scheme HelloObjectiveC -arch x86_64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean 	build | xcpretty -c || exit 13

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

echo "Building iOS SporthEditor"
xcodebuild -project Examples/iOS/SporthEditor/SporthEditor.xcodeproj -sdk iphonesimulator -scheme SporthEditor -arch x86_64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 20

echo "Building macOS AKSamplerDemo"
xcodebuild -project Examples/macOS/AKSamplerDemo/AKSamplerDemo.xcodeproj -scheme AKSamplerDemo ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 21

echo "Building macOS AudioUnitManager"
xcodebuild -project Examples/macOS/AudioUnitManager/AudioUnitManager.xcodeproj -scheme AudioUnitManager	ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 22

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

echo "Building macOS SporthEditor"
xcodebuild -project Examples/macOS/SporthEditor/SporthEditor.xcodeproj -scheme SporthEditor ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 29

echo "Skipping Particles - requires hardware"
#xcodebuild -project Examples/iOS/Particles/AudioKitParticles.xcodeproj -sdk iphonesimulator -scheme AudioKitParticles ONLY_ACTIVE_ARCH=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 30

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
xcodebuild -scheme iOSTestSuite -project Tests/iOSTestSuite/iOSTestSuite.xcodeproj test -sdk iphonesimulator  -destination 'platform=iOS Simulator,name=iPhone 8,OS=11.2' | xcpretty -c || exit 100

echo "Skipping macOS Unit Tests on Travis until they run macOS 10.13"
#xcodebuild -project Tests/macOSTestSuite/macOSTestSuite.xcodeproj -scheme macOSTestSuite test ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" | xcpretty -c || exit 101
