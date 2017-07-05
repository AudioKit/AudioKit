#!/bin/bash
#
# Builds packages for release of the current version of AudioKit.
#
set -o pipefail

VERSION=$(cat ../VERSION)
PLATFORMS=${PLATFORMS:-"iOS tvOS macOS"}

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

# Generate documentation to include in the zip files
if test "$SKIP_JAZZY" = ""; 
then
	jazzy -c --theme apple --source-directory ../AudioKit/iOS/ \
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
	cp -a "$DIR/AudioKit.framework" "Carthage/$os/"
	cd $DIR
	mkdir -p Examples
	cp -a ../../Examples/$1/* Examples/
	# Exceptions of any example projects to skip
	rm -rf Examples/SongProcessor
	find Examples -name project.pbxproj -exec gsed -i -f ../fix_paths.sed {} \;
	find -d Examples -name Pods -exec rm -rf {} \;
	find Examples -name Podfile.lock -exec rm -rf {} \;
	cp ../../README.md ../../VERSION ../../LICENSE ../README.md .
	cp -a ../docs/docsets/AudioKit.docset .
	find . -name .DS_Store -exec rm -rf {} \;
	find -d . -name build -exec rm -rf {} \;
	find -d . -name xcuserdata -exec rm -rf {} \;
	cd ..
	zip -9yr ${DIR}-${VERSION}.zip $DIR
}

create_playgrounds()
{
	echo "Packaging AudioKit Playgrounds version $VERSION ..."
	cp -a ../Playgrounds AudioKitPlaygrounds
	cd AudioKitPlaygrounds
	cp -a ../AudioKit-macOS/AudioKit.framework AudioKitPlaygrounds/
	gsed -i "s/\.\.\/\.\.\/Frameworks\/AudioKit-macOS/\./g" AudioKitPlaygrounds.xcodeproj/project.pbxproj
	gsed -i "s/\.\.\/Frameworks\/AudioKit-macOS//g" AudioKitPlaygrounds.xcodeproj/project.pbxproj
	cp ../../README.md ../../LICENSE .
	find . -name .DS_Store -or -name build -or -name xcuserdata -exec rm -rf {} \;
	cd ..
        zip -9yr AudioKitPlaygrounds-${VERSION}.zip AudioKitPlaygrounds
}

for os in $PLATFORMS;
do
	create_package $os
done

create_playgrounds

# Create binary framework zip for Carthage, to be uploaded to Github along with release

echo "Packaging AudioKit frameworks version $VERSION for Carthage ..."
rm -f AudioKit.framework.zip
cd Carthage
cp ../../LICENSE .
zip -9yr ../AudioKit.framework.zip $PLATFORMS LICENSE

