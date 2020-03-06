#!/bin/bash
#
# Building examples and unit tests on tvOS
#
if test `find . -name \*.pbxproj -exec grep -H /Users/ {} \;|tee /tmp/found|wc -l` -gt 0; then
	echo "Found some absolute references to user directories in the projects. This should be fixed!"
	cat /tmp/found
	exit 1
fi
set -o pipefail

echo "Building tvOS HelloWorld"
xcodebuild -project Examples/tvOS/HelloWorld/HelloWorld.xcodeproj -sdk appletvsimulator -scheme HelloWorld ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c || exit 6
