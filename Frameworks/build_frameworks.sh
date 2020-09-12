#!/bin/bash
#
# Build AudioKit universal frameworks suited for distribution.
#
set -o pipefail

PROJECT_NAME=AudioKit
PROJECT_UI_NAME=AudioKitUI
CONFIGURATION=${CONFIGURATION:-"Release"}
STAGING_BRANCH="staging"
BUILD_DIR="$PWD/build"

for parameter in $*; do
    if test $parameter = '-?'; then
        echo "Usage:"
        echo ""
        echo "PLATFORMS=\"iOS\" ./build_frameworks.sh"
        echo "or"
        echo "PLATFORMS=\"macOS\" ./build_frameworks.sh"
        echo "or"
        echo "PLATFORMS=\"tvOS\" ./build_frameworks.sh"
        echo "or"
        echo "PLATFORMS=\"iOS macOS\" ./build_frameworks.sh"
        echo "or"
        echo "./build_frameworks.sh"
        exit 0
    fi
done

if [ ! -f build_frameworks.sh ]; then
    echo "This script needs to be run from the Frameworks folder"
    exit 0
fi

(cd ..; swift package generate-xcodeproj --xcconfig-overrides AudioKit.xcconfig)

VERSION=$(cat ../VERSION)
FRAMEWORKS=$(cat Frameworks.list)
PLATFORMS=${PLATFORMS:-"iOS macOS tvOS"}

if [[ "$TRAVIS" = true ]];
then
	echo "Travis detected, build #$TRAVIS_BUILD_NUMBER"
	if [[ "$TRAVIS_BRANCH" = "$STAGING_BRANCH" ]]; then # Staging build
		ACTIVE_ARCH=NO
		XCSUFFIX=""
		VERSION="${VERSION}.b1"
	elif [[ "$TRAVIS_TAG" != "" ]]; then  # Release build
		ACTIVE_ARCH=NO
		XCSUFFIX=""
	else # Test build
		ACTIVE_ARCH=YES
		XCSUFFIX="-travis"
		SIMULATOR_ONLY=true
		PLATFORMS="iOS macOS" # Skipping tvOS?
	fi
elif [[ "$GITHUB_ACTION" != "" ]]; then
	echo "GitHub Actions Workflow detected, run #$GITHUB_RUN_ID"
	if [[ "$GITHUB_REF" != "refs/heads/staging" ]] && [[ "$GITHUB_REF" != refs/tag/* ]]; then
		ACTIVE_ARCH=YES
		XCSUFFIX="-travis"
		SIMULATOR_ONLY=true
	else
		ACTIVE_ARCH=NO
		XCSUFFIX=""
	fi
else # Regular command-line assumed
	ACTIVE_ARCH=NO
	XCSUFFIX=""
fi

if which xcpretty > /dev/null 2>&1;
then
	XCPRETTY=xcpretty
else
	XCPRETTY=cat
fi

# Provide 3 arguments: platform (iOS or tvOS), simulator os, native os
create_universal_frameworks()
{
	PROJECT="../AudioKit.xcodeproj"
	DIR="AudioKit-$1"
	rm -rf $DIR/*.framework
	mkdir -p "$DIR"
	xcodebuild -project "$PROJECT" -target "AudioKit" -xcconfig simulator${XCSUFFIX}.xcconfig -configuration ${CONFIGURATION} -sdk $2 \
		BUILD_DIR="${BUILD_DIR}" CURRENT_PROJECT_VERSION="$VERSION" clean build | tee -a build.log | $XCPRETTY || exit 2
	for f in ${PROJECT_NAME} $FRAMEWORKS; do
		cp -av "${BUILD_DIR}/${CONFIGURATION}-$2/${f}.framework" "$DIR/"
		if test -d  "${BUILD_DIR}/${CONFIGURATION}-$2/${f}.framework.dSYM"; then
			echo "Building dynamic framework for $f"
			DYNAMIC_UI=true
			cp -av "${BUILD_DIR}/${CONFIGURATION}-$2/${f}.framework.dSYM" "$DIR/"
			cp -v fix-framework.sh "${DIR}/${f}.framework/"
		else
			echo "Building static framework for $f"
		fi
	done
	
	if test "$SIMULATOR_ONLY" = true;
	then # Only build for simulator on Travis CI, unless we're building a release
		for f in ${PROJECT_NAME} $FRAMEWORKS; do
			cp -v "${BUILD_DIR}/${CONFIGURATION}-$2/${f}.framework/${f}" "${DIR}/${f}.framework/"
			if test -d "${BUILD_DIR}/${CONFIGURATION}-$2/${f}.framework/Modules/${f}.swiftmodule/"; then
				cp -av "${BUILD_DIR}/${CONFIGURATION}-$2/${f}.framework/Modules/${f}.swiftmodule/"* "${DIR}/${f}.framework/Modules/${f}.swiftmodule/"
			fi
		done
	else # Build device slices
		xcodebuild -project "$PROJECT" -target "AudioKit" -xcconfig device.xcconfig -configuration ${CONFIGURATION} -sdk $3 \
			BUILD_DIR="${BUILD_DIR}" CURRENT_PROJECT_VERSION="$VERSION" clean build | tee -a build.log | $XCPRETTY || exit 3
		for f in ${PROJECT_NAME} $FRAMEWORKS; do
			if test -d "${BUILD_DIR}/${CONFIGURATION}-$3/${f}.framework/Modules/${f}.swiftmodule/"; then
				cp -av "${BUILD_DIR}/${CONFIGURATION}-$3/${f}.framework/Modules/${f}.swiftmodule/"* \
					"${DIR}/${f}.framework/Modules/${f}.swiftmodule/"
			fi
			cp -v "${BUILD_DIR}/${CONFIGURATION}-$3/${f}.framework/Info.plist" "${DIR}/${f}.framework/"
			# Merge the frameworks proper - apparently it's important that device OS is first starting in Xcode 10.2
			lipo -create -output "${DIR}/${f}.framework/${f}" \
				"${BUILD_DIR}/${CONFIGURATION}-$3/${f}.framework/${f}" \
				"${BUILD_DIR}/${CONFIGURATION}-$2/${f}.framework/${f}" || exit 4
		done
		if test "$DYNAMIC" = true;
		then
			mkdir -p "${DIR}/${PROJECT_NAME}.framework/BCSymbolMaps"
			# Doesn't seem to have a way to tell which bcsymbolmap belongs to which framework
			cp -av "${BUILD_DIR}/${CONFIGURATION}-$3"/*.bcsymbolmap "${DIR}/${PROJECT_NAME}.framework/BCSymbolMaps/"
			# Merge the dSYM files
			lipo -create -output "${DIR}/${PROJECT_NAME}.framework.dSYM/Contents/Resources/DWARF/${PROJECT_NAME}" \
				"${BUILD_DIR}/${CONFIGURATION}-$2/${PROJECT_NAME}.framework.dSYM/Contents/Resources/DWARF/${PROJECT_NAME}" \
				"${BUILD_DIR}/${CONFIGURATION}-$3/${PROJECT_NAME}.framework.dSYM/Contents/Resources/DWARF/${PROJECT_NAME}" || exit 5
		else # Strip debug symbols from static library
			strip -S "${DIR}/${PROJECT_NAME}.framework/${PROJECT_NAME}"
		fi
		if test "$DYNAMIC_UI" = true;
		then
			for f in $FRAMEWORKS; do
				mkdir -p "${DIR}/${f}.framework/BCSymbolMaps"
				# Doesn't seem to have a way to tell which bcsymbolmap belongs to which framework
				UIBC=`fgrep -Hn $f "${BUILD_DIR}/${CONFIGURATION}-$3"/*.bcsymbolmap|awk -F: '{print $1}'|uniq`
				cp -av $UIBC "${DIR}/${f}.framework/BCSymbolMaps/"
				# Merge the dSYM files
				lipo -create -output "${DIR}/${f}.framework.dSYM/Contents/Resources/DWARF/${f}" \
					"${BUILD_DIR}/${CONFIGURATION}-$2/${f}.framework.dSYM/Contents/Resources/DWARF/${f}" \
					"${BUILD_DIR}/${CONFIGURATION}-$3/${f}.framework.dSYM/Contents/Resources/DWARF/${f}" || exit 5
			done
		else # Strip debug symbols from static library
			for f in $FRAMEWORKS; do
				strip -S "${DIR}/${f}.framework/${f}"
			done
		fi
		# Swift 5 / Xcode 10.2 bug (!?) - must combine the generated AudioKit-Swift.h headers
		for fw in ${PROJECT_NAME} ${FRAMEWORKS};
		do
			if test -f "${BUILD_DIR}/${CONFIGURATION}-$2/${fw}.framework/Headers/${fw}-Swift.h"; then
				echo '#include <TargetConditionals.h>' > "${DIR}/${fw}.framework/Headers/${fw}-Swift.h"
				echo '#if TARGET_OS_SIMULATOR' >> "${DIR}/${fw}.framework/Headers/${fw}-Swift.h"
				cat "${BUILD_DIR}/${CONFIGURATION}-$2/${fw}.framework/Headers/${fw}-Swift.h" >> "${DIR}/${fw}.framework/Headers/${fw}-Swift.h"
				echo '#else' >> "${DIR}/${fw}.framework/Headers/${fw}-Swift.h"
				cat "${BUILD_DIR}/${CONFIGURATION}-$3/${fw}.framework/Headers/${fw}-Swift.h" >> "${DIR}/${fw}.framework/Headers/${fw}-Swift.h"
				echo '#endif' >> "${DIR}/${fw}.framework/Headers/${fw}-Swift.h"
			fi
		done
	fi
}

# Create individual static platform frameworks (device or simulator) in their own subdirectories
# 2 arguments: platform (iOS or tvOS), platform (iphoneos, iphonesimulator, appletvos, appletvsimulator)
create_framework()
{
	PROJECT="../AudioKit.xcodeproj"
	DIR="AudioKit-$1/$2"
	rm -rf "$DIR/$PROJECT_NAME.framework" "$DIR/$PROJECT_UI_NAME.framework"
	mkdir -p "$DIR"
	if test "$2" = iphonesimulator -o "$2" = appletvsimulator; then
		XCCONFIG=simulator${XCSUFFIX}.xcconfig
	else
		XCCONFIG=device.xcconfig
	fi
	echo "Building static frameworks for $1 / $2"
	xcodebuild -project "$PROJECT" -target "AudioKit" -xcconfig ${XCCONFIG} -configuration ${CONFIGURATION} -sdk $2 \
		BUILD_DIR="${BUILD_DIR}" CURRENT_PROJECT_VERSION="$VERSION" clean build | tee -a build.log | $XCPRETTY || exit 2
	for f in ${PROJECT_NAME} $FRAMEWORKS; do
		cp -av "${BUILD_DIR}/${CONFIGURATION}-$2/${f}.framework" "$DIR/"
		strip -S "${DIR}/${f}.framework/${f}"
	done
}


# Provide 2 arguments: platform (macOS), native os (macosx)
create_macos_frameworks()
{
	PROJECT="../AudioKit.xcodeproj"
	DIR="AudioKit-$1"
	rm -rf ${DIR}/*.framework
	mkdir -p "$DIR"
	xcodebuild -project "$PROJECT" -target "AudioKit" ONLY_ACTIVE_ARCH=$ACTIVE_ARCH CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" DEFINES_MODULE=YES \
		-configuration ${CONFIGURATION} -sdk $2 BUILD_DIR="${BUILD_DIR}" CURRENT_PROJECT_VERSION="$VERSION" clean build | tee -a build.log | $XCPRETTY || exit 2
	for f in ${PROJECT_NAME} $FRAMEWORKS; do
		cp -av "${BUILD_DIR}/${CONFIGURATION}/${f}.framework" "$DIR/"
		if test -d  "${BUILD_DIR}/${CONFIGURATION}/${f}.framework.dSYM";
		then
			cp -av "${BUILD_DIR}/${CONFIGURATION}/${f}.framework.dSYM" "$DIR/"
		else
			strip -S "${DIR}/${f}.framework/${f}"
		fi
	done
}

# Make a UIKitforMac version (maccatalyst) from the iOS project, but package with the Mac version
create_catalyst_frameworks()
{
	if test $OSTYPE = darwin19; then
		echo "Building Mac Catalyst framework"
	else
		echo "Skipping Catalyst build, macOS Catalina is required"
		return
	fi
	PROJECT="../AudioKit.xcodeproj"
	DIR="AudioKit-macOS/Catalyst"
	rm -rf ${DIR}/*.framework
	mkdir -p "$DIR"
	xcodebuild archive -project "$PROJECT" -scheme AudioKit-Package ONLY_ACTIVE_ARCH=$ACTIVE_ARCH SDKROOT=iphoneos \
			CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" SKIP_INSTALL=NO DEFINES_MODULE=YES APPLY_RULES_IN_COPY_HEADERS=YES \
			-configuration ${CONFIGURATION} -destination 'platform=macOS,variant=Mac Catalyst' -archivePath "${BUILD_DIR}/Catalyst.xcarchive" \
			BUILD_DIR="${BUILD_DIR}" CURRENT_PROJECT_VERSION="$VERSION" | tee -a build.log | $XCPRETTY || exit 2
	for f in ${PROJECT_NAME} $FRAMEWORKS; do
		cp -av "${BUILD_DIR}/Catalyst.xcarchive/Products/Library/Frameworks/${f}.framework" "$DIR/"
		if test -d  "${BUILD_DIR}/${CONFIGURATION}/${f}.framework.dSYM";
		then
			cp -av "${BUILD_DIR}/${CONFIGURATION}/${f}.framework.dSYM" "$DIR/"
		else
			strip -S "${DIR}/${f}.framework/${f}"
		fi
	done

	# Finally, replace the symlinks created in the build directory by the actual archive, so they can be copied as build artifacts
	if [ -L "${BUILD_DIR}/${CONFIGURATION}-maccatalyst/${PROJECT_NAME}.framework" ];
	then
		for f in ${PROJECT_NAME} $FRAMEWORKS; do
			LINK=$(readlink "${BUILD_DIR}/${CONFIGURATION}-maccatalyst/${f}.framework")
			rm "${BUILD_DIR}/${CONFIGURATION}-maccatalyst/${f}.framework"
			cp -a "$LINK" "${BUILD_DIR}/${CONFIGURATION}-maccatalyst/${f}.framework"
		done
	fi
}

echo "Building frameworks for version $VERSION on platforms: $PLATFORMS"
rm -f build.log

for os in $PLATFORMS; do
	if test $os = 'iOS'; then
		#create_universal_frameworks iOS iphonesimulator iphoneos
		create_framework iOS iphoneos
		create_framework iOS iphonesimulator
	elif test $os = 'tvOS'; then
		#create_universal_frameworks tvOS appletvsimulator appletvos
		create_framework tvOS appletvos
		create_framework tvOS appletvsimulator
	elif test $os = 'macOS'; then
		create_macos_frameworks macOS macosx
		create_catalyst_frameworks
	fi
done

if [ -f distribute_built_frameworks.sh ]; then
    ./distribute_built_frameworks.sh
fi

