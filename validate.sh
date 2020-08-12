#!/bin/bash

set -e

cd Frameworks
sh build_frameworks.sh
sh build_xcframework.sh 
cd ..
sh Tests/test-iOS.sh
