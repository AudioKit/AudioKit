#!/bin/bash
#
# Builds packages for release of the current versino of AudioKit.
#
set -o pipefail

VERSION=$(cat ../VERSION)
PLATFORMS=${PLATFORMS:-"iOS tvOS OSX"}

if ! test -d AudioKit-iOS;
then
	./build_frameworks.sh
fi

# Includes the framework and all example projects for the platform
# Should also include an appropriate README and license file eventually.

create_package()
{
	echo "Packaging AudioKit version $VERSION for $1 ..."
	DIR="AudioKit-$1"
	cd $DIR
	mkdir -p Examples
	cp -a ../../Examples/$1/* Examples/
	find Examples -name project.pbxproj -exec sed -i -f ../fix_paths.sed {} \;
	cp ../../README.md ../../VERSION .
	find . -name .DS_Store -exec rm -f {} \;
	cd ..
	zip -9yr ${DIR}-${VERSION}.zip $DIR
}

for os in $PLATFORMS;
do
	create_package $os
done

