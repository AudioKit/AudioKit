#!/bin/bash
BUILDCONF=${BUILDCONF:-Testing}
for i in Tests/*
  do
    cp $i AuditionSounds/AuditionSounds/main.swift
    name=${i/Tests\//}
    echo ""
    echo ""
    echo "======================================"
    echo " $name "
    echo "======================================"
    echo ""
    cd AuditionSounds
    xcodebuild | xcpretty
    cd ./build/$BUILDCONF/
    mkdir -p built
    execfile=$i
    execfile=${execfile/Tests/}
    execfile=${execfile/.swift/}
    cp ./AuditionSounds built/$execfile
    cd ../../..
  done
