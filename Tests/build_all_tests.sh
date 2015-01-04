#!/bin/bash
for i in AK*
  do
    echo "Building " $i
    cd $i
    xcodebuild
    cd ..
  done
