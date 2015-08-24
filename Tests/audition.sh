#!/bin/bash
BUILDCONF=${BUILDCONF:-Testing}
if [ ${#@} == 1 ]; then
  TEST=$1
else
  PS3='Enter your choice: '
  options=(
      "Play all sounds"
      "Choose sounds from list"
  )
  select opt in "${options[@]}"
  do
      case $opt in
          "Play all sounds")
              TEST="All"
              break
              ;;
          "Choose sounds from list")
              TEST="Choose"
              break
              ;;
          *) echo invalid option;;
      esac
  done

  if [ $TEST == "Choose" ]; then
      PS3='\nEnter the number you want to hear: '
      options=($(ls Tests))
      select opt in "${options[@]}"
      do
          TEST=Tests/$opt
          break
      done
  else
    cd AuditionSounds/build/$BUILDCONF/
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
cp $TEST AuditionSounds/AuditionSounds/main.swift
cd AuditionSounds
echo ""
echo ""
echo "======================================"
echo " $TEST "
echo "======================================"
echo ""
xcodebuild | xcpretty || exit 1
echo "./build/$BUILDCONF/"
cd ./build/$BUILDCONF/
mkdir -p built
execfile=$TEST
execfile=${execfile/Tests/}
execfile=${execfile/.swift/}
echo "./AudioKitTest built/$execfile"
cp ./AuditionSounds "built/$execfile"
"./built/$execfile"
