#!/bin/bash
for i in AK*
  do
    cd $i/build/Release
    ./$i
    cd ../../..
  done
