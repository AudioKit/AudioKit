#!/bin/bash
BUILDCONF=${BUILDCONF:-Testing}
for i in Tests/*
  do
    cp $i AudioKitTest/AudioKitTest/main.swift
    name=${i/Tests\//}
    echo ""
    echo ""
    echo "======================================"
    echo " $name "
    echo "======================================"
    echo ""
    cd AudioKitTest
    xcodebuild | xcpretty
    cd ./build/$BUILDCONF/
    mkdir -p built
    execfile=$i
    execfile=${execfile/Tests/}
    execfile=${execfile/.swift/}
    cp ./AudioKitTest built/$execfile
    cd ../../..
  done
