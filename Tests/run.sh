#!/bin/bash
if [ ${#@} == 0 ]; then
    echo "Usage: $0 AKTestName"
    exit
fi
cp $1 AudioKitTest/AudioKitTest/main.swift
cd AudioKitTest
echo ""
echo ""
echo "======================================"
echo " $1 "
echo "======================================"
echo ""
xcodebuild >& /dev/null
cd ./build/Release/
mkdir -p built
execfile=$1
execfile=${execfile/Tests/}
execfile=${execfile/.swift/}
cp ./AudioKitTest built/$execfile
./built/$execfile
