#!/bin/bash
for i in *
  do
    echo "Building " $i
    cd $i
    xcodebuild
    cd ..
  done
