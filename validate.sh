
set -e -o pipefail
swift package generate-xcodeproj --xcconfig-overrides AudioKit.xcconfig
xcodebuild -project AudioKit.xcodeproj -scheme AudioKit-Package clean test | xcpretty -c
xcodebuild -project AudioKit.xcodeproj -scheme AudioKit-Package -destination 'platform=iOS Simulator,name=iPhone 11,OS=13.6' clean test | xcpretty -c
