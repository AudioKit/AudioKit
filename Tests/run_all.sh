#!/bin/bash
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
