#!/bin/bash
if [ ${#@} == 1 ]; then
  TEST=$1
else
  PS3='Enter your choice: '
  options=(
      "Run All Tests"
      "Choose Test from List"
  )
  select opt in "${options[@]}"
  do
      case $opt in
          "Run All Tests")
              TEST="All"
              break
              ;;
          "Choose Test from List")
              TEST="Choose"
              break
              ;;
          *) echo invalid option;;
      esac
  done

  if [ $TEST == "Choose" ]; then
      PS3='\nEnter the number of the test you want: '
      options=($(ls Tests))
      select opt in "${options[@]}"
      do
          TEST=Tests/$opt
          break
      done
  else
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
fi
cp $TEST AudioKitTest/AudioKitTest/main.swift
cd AudioKitTest
echo ""
echo ""
echo "======================================"
echo " $TEST "
echo "======================================"
echo ""
xcodebuild | xcpretty || exit 1
cd ./build/Release/
mkdir -p built
execfile=$TEST
execfile=${execfile/Tests/}
execfile=${execfile/.swift/}
cp ./AudioKitTest built/$execfile
./built/$execfile
