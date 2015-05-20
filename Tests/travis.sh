#!/bin/bash
if test `find . -name \*.pbxproj -exec grep -H /Users/ {} \;|tee /tmp/found|wc -l` -gt 0; then
	cat /tmp/found
	exit 1
fi
set -o pipefail
xcodebuild -scheme OSXObjectiveCAudioKitTests -project Tests/TestProjects/OSXObjectiveCAudioKit/OSXObjectiveCAudioKit.xcodeproj test | xcpretty -c || exit 2
xcodebuild -project Examples/iOS/AudioKitDemo/AudioKitDemo.xcodeproj       -sdk iphonesimulator ONLY_ACTIVE_ARCH=NO build | xcpretty -c || exit 3
xcodebuild -project Examples/iOS/HelloWorld/HelloWorld.xcodeproj           -sdk iphonesimulator ONLY_ACTIVE_ARCH=NO build | xcpretty -c || exit 4
xcodebuild -project Examples/iOS/Swift/AudioKitDemo/AudioKitDemo.xcodeproj -sdk iphonesimulator ONLY_ACTIVE_ARCH=NO build | xcpretty -c || exit 5
xcodebuild -project Examples/iOS/Swift/HelloWorld/HelloWorld.xcodeproj     -sdk iphonesimulator ONLY_ACTIVE_ARCH=NO build | xcpretty -c || exit 6
cp Playgrounds/Playgrounds/DefaultPlayground.m Playgrounds/AudioKitPlayground/AudioKitPlayground/Playground.m || exit 7
xcodebuild -workspace Playgrounds/AudioKitPlayground/AudioKitPlayground.xcworkspace -scheme AudioKitPlayground -sdk iphonesimulator ONLY_ACTIVE_ARCH=NO build | xcpretty -c || exit 8
pod lib lint --quick AudioKit.podspec.json || exit 9

