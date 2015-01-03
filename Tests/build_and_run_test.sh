#!/bin/bash
if [ ${#@} == 0 ]; then
    echo "Usage: $0 AKTestName"
    exit
fi
cd $1
xcodebuild
cd build/Release
./$1
