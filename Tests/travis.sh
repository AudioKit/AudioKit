#!/bin/bash
if test `find . -name \*.pbxproj -exec grep -H /Users/ {} \;|tee /tmp/found|wc -l` -gt 0; then
	cat /tmp/found
	exit 1
fi
set -o pipefail
xcodebuild -scheme OSXAudioKit -project Tests/OSXAudioKit/OSXAudioKit.xcodeproj test | xcpretty -c || exit 2

