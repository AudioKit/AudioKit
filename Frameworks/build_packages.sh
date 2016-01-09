#!/bin/bash
#
# Builds packages for release of the current versino of AudioKit.
#
set -o pipefail

VERSION=$(cat ../VERSION)

if ! test -d iOS;
then
	./build_frameworks.sh
fi

# Includes the framework and all example projects for the platform
# Should also include an appropriate README and license file eventually.

create_package()
{
	echo "Packaging AudioKit version $VERSION for $1 ..."
	DIR="AudioKit-$1-$VERSION"
	cd $DIR
	mkdir -p Examples
	cp -a ../../Examples/$1/* Examples/
	cp ../../README.md .
	cd ..
	zip -9yr ${DIR}.zip $DIR
}

for os in iOS tvOS OSX;
do
	create_package $os
done

