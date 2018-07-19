#!/bin/bash
#
# Builds packages for release of the current version of AudioKit.
#
set -o pipefail

VERSION=$(cat ../VERSION)
PLATFORMS=${PLATFORMS:-"iOS tvOS macOS"}
SKIP_JAZZY=1 # Broken for now
SUBDIR=${SUBDIR:-"packages"}
STAGING_BRANCH="staging"

if ! which gsed > /dev/null 2>&1;
then
	echo "You need GNU sed installed to run this script properly!"
	echo "  brew install gnu-sed"
	exit 1
fi

if ! test -d AudioKit-iOS;
then
	./build_frameworks.sh
fi

if ! test -d "$SUBDIR";
then
	mkdir "$SUBDIR"
fi

# Generate documentation to include in the zip files
if test "$SKIP_JAZZY" = ""; 
then
	jazzy -c --theme apple --source-directory ../AudioKit/iOS/ \
		-x -target,AudioKitDocs \
		--module-version $VERSION \
		--github-file-prefix https://github.com/audiokit/AudioKit/tree/v$VERSION \
	|| exit 1
fi

# Includes the framework and all example projects for the platform

create_package()
{
	echo "Packaging AudioKit version $VERSION for $1 ..."
	DIR="AudioKit-$1"
	rm -f ${DIR}-${VERSION}.zip
	mkdir -p "Carthage/$os"
	cp -a "$DIR/AudioKit.framework" "$DIR/AudioKitUI.framework" "Carthage/$os/"
	test "$TRAVIS_BRANCH" = "$STAGING_BRANCH" && return
	cd $DIR
	mkdir -p Examples
	cp -a ../../Examples/$1/* Examples/
	# Exceptions of any example projects to skip
	rm -rf Examples/SongProcessor
	find Examples -name project.pbxproj -exec gsed -i -f ../fix_paths.sed {} \;
	find -d Examples -name Pods -exec rm -rf {} \;
	find Examples -name Podfile.lock -exec rm -rf {} \;
	cp ../../README.md ../../VERSION ../../LICENSE ../README.md .
	test -d ../docs && cp -a ../docs/docsets/AudioKit.docset .
	find . -name .DS_Store -exec rm -rf {} \;
	find -d . -name build -exec rm -rf {} \;
	find -d . -name xcuserdata -exec rm -rf {} \;
	cd ..
	zip -9yr ${SUBDIR}/${DIR}-${VERSION}.zip $DIR
}

create_playgrounds()
{
	echo "Packaging AudioKit Playgrounds version $VERSION ..."
	rm -rf AudioKitPlaygrounds-${VERSION}.zip AudioKitPlaygrounds
	cp -a ../Playgrounds AudioKitPlaygrounds
	cd AudioKitPlaygrounds
	cp -a ../AudioKit-macOS/AudioKit.framework ../AudioKit-macOS/AudioKitUI.framework AudioKitPlaygrounds/
	gsed -i "s/\.\.\/Frameworks\/AudioKit-macOS/AudioKitPlaygrounds/g" AudioKitPlaygrounds.xcodeproj/project.pbxproj
	cp ../../README.md ../../LICENSE .
	find . -name .DS_Store -exec rm -rf {} \;
	find . -name build -or -name xcuserdata -exec rm -rf {} \;
	cd ..
        zip -9yr ${SUBDIR}/AudioKitPlaygrounds-${VERSION}.zip AudioKitPlaygrounds
}

rm -rf Carthage

for os in $PLATFORMS;
do
	create_package $os
done

test "$TRAVIS_BRANCH" != "$STAGING_BRANCH" && create_playgrounds

# Create binary framework zip for Carthage/CocoaPods, to be uploaded to S3 or GitHub along with release

echo "Packaging AudioKit frameworks version $VERSION for CocoaPods and Carthage ..."
rm -f AudioKit.framework.zip
cd Carthage
cp ../../LICENSE ../../README.md .
zip -9yr ../${SUBDIR}/AudioKit.framework.zip $PLATFORMS LICENSE README.md

