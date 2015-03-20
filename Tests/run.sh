#!/bin/bash
if [ ${#@} == 0 ]; then
  echo "**** Since no test was provided, we'll run all built tests. ****"
  cd AudioKitTest/build/Release/
  for i in built/*
    do
      name=${i/built\//}
      echo ""
      echo ""
      echo "======================================"
      echo " $name "
      echo "======================================"
      echo ""
      ./$i
    done
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
