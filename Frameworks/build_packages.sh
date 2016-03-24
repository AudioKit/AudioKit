#!/bin/bash
#
# Builds packages for release of the current version of AudioKit.
#
set -o pipefail

VERSION=$(cat ../VERSION)
PLATFORMS=${PLATFORMS:-"iOS tvOS OSX"}

if ! which gsed > /dev/null 2>&1;
then
	echo "You need GNU sed installed to run this script properly!"
	exit 1
fi

if ! test -d AudioKit-iOS;
then
	./build_frameworks.sh
fi

# Generate documentation to include in the zip files

jazzy -c --theme apple --source-directory ../AudioKit/iOS/ \
	--module-version $VERSION \
	--github-file-prefix https://github.com/audiokit/AudioKit/tree/v$VERSION \
|| exit 1

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
	find Examples -name project.pbxproj -exec gsed -i -f ../fix_paths.sed {} \;
	cp ../../README.md ../../VERSION ../../LICENSE ../INSTALL.md .
	cp -a ../docs/docsets/AudioKit.docset .
	find . -name .DS_Store -or -name build -exec rm -f {} \;
	cd ..
	zip -9yr ${DIR}-${VERSION}.zip $DIR
}

for os in $PLATFORMS;
do
	create_package $os
done

# Create binary framework zip for Carthage, to be uploaded to Github along with release

echo "Packaging AudioKit frameworks version $VERSION for Carthage ..."
rm -f AudioKit.framework.zip
cd Carthage
cp ../../LICENSE .
zip -9yr ../AudioKit.framework.zip $PLATFORMS LICENSE

