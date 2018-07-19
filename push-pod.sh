#!/bin/bash
# This script pushes a new version of the podspec to either the public specs (for releases), or the private AK Specs repo (for regular staging)

if test $# -lt 1;
then
	echo "Usage: $0 release|staging"
	exit 1
fi

VER=$(cat VERSION)

if test $1 = release;
then
	SOURCE="https://files.audiokit.io/releases/v${VER}/AudioKit.framework.zip"
elif test $1 = staging;
then
	SOURCE="https://files.audiokit.io/staging/v${VER}/AudioKit.framework.zip"
else
	echo "Invalid parameter: $1"
	exit 1
fi

# Make sure you have added the AK Specs repo as ak-specs
if ! test -d ~/.cocoapods/repos/ak-specs;
then
	pod repo add ak-specs git@github.com:AudioKit/Specs.git
fi

cat AudioKit.podspec.json.tmpl | sed "s/__AK_VERSION__/$VER/" | sed "s|__AK_SOURCE__|$SOURCE|" > AudioKit.podspec.json

if test $1 = release;
then
	pod trunk push AudioKit.podspec.json --verbose
else # Staging
	pod repo push ak-specs AudioKit.podspec.json --verbose
fi
