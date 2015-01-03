#!/bin/bash
for i in *
  do
    cd $i/build/Release
    ./$i
    cd ../../..
  done
