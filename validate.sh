
set -e
swift package generate-xcodeproj --xcconfig-overrides AudioKit.xcconfig
xcodebuild -project AudioKit.xcodeproj -scheme AudioKit-Package clean test | xcpretty -c
