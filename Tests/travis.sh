#!/bin/bash
if test `find . -name \*.pbxproj -exec grep -H /Users/ {} \;|tee /tmp/found|wc -l` -gt 0; then
	cat /tmp/found
	exit 1
fi
set -o pipefail
xcodebuild -scheme OSXObjectiveCAudioKitTests -project Tests/TestProjects/OSXObjectiveCAudioKit/OSXObjectiveCAudioKit.xcodeproj test | xcpretty -c || exit 2
xcodebuild -scheme iOSObjectiveCAudioKitTests -project Tests/TestProjects/iOSObjectiveCAudioKit/iOSObjectiveCAudioKit.xcodeproj test -destination 'platform=iOS Simulator,name=iPhone 5s' | xcpretty -c || exit 2
xcodebuild -project Examples/iOS/AudioKitDemo/AudioKitDemo.xcodeproj       -sdk iphonesimulator ONLY_ACTIVE_ARCH=NO build | xcpretty -c || exit 3
xcodebuild -project Examples/iOS/HelloWorld/HelloWorld.xcodeproj           -sdk iphonesimulator ONLY_ACTIVE_ARCH=NO build | xcpretty -c || exit 4
xcodebuild -project Examples/iOS/Swift/AudioKitDemo/AudioKitDemo.xcodeproj -sdk iphonesimulator ONLY_ACTIVE_ARCH=NO build | xcpretty -c || exit 5
xcodebuild -project Examples/iOS/Swift/HelloWorld/HelloWorld.xcodeproj     -sdk iphonesimulator ONLY_ACTIVE_ARCH=NO build | xcpretty -c || exit 6
xcodebuild -project Examples/OSX/AudioKitDemo/AudioKitDemo.xcodeproj build | xcpretty -c || exit 7
xcodebuild -project Examples/OSX/HelloWorld/HelloWorld.xcodeproj     build | xcpretty -c || exit 8

cp Playgrounds/Playgrounds/DefaultPlayground.m Playgrounds/AudioKitPlayground/AudioKitPlayground/Playground.m || exit 9
xcodebuild -workspace Playgrounds/AudioKitPlayground/AudioKitPlayground.xcworkspace -scheme AudioKitPlayground -sdk iphonesimulator ONLY_ACTIVE_ARCH=NO build | xcpretty -c || exit 10
pod lib lint --quick AudioKit.podspec.json || exit 11

