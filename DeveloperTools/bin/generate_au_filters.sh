#!/bin/bash
./bin/generate_au_swift.rb interfaces/Filters/AUBandPassFilter.swift > ../AudioKit/Common/Nodes/Effects/Filters/Band\ Pass\ Filter/AKBandPassFilter.swift
./bin/generate_au_swift.rb interfaces/Filters/AUHighPassFilter.swift  > ../AudioKit/Common/Nodes/Effects/Filters/High\ Pass\ Filter/AKHighPassFilter.swift
./bin/generate_au_swift.rb interfaces/Filters/AUHighShelfFilter.swift  > ../AudioKit/Common/Nodes/Effects/Filters/High\ Shelf\ Filter/AKHighShelfFilter.swift
./bin/generate_au_swift.rb interfaces/Filters/AULowPassFilter.swift  > ../AudioKit/Common/Nodes/Effects/Filters/Low\ Pass\ Filter/AKLowPassFilter.swift
./bin/generate_au_swift.rb interfaces/Filters/AULowShelfFilter.swift  > ../AudioKit/Common/Nodes/Effects/Filters/Low\ Shelf\ Filter/AKLowShelfFilter.swift
./bin/generate_au_swift.rb interfaces/Filters/AUParametricEQ.swift  > ../AudioKit/Common/Nodes/Effects/Filters/Parametric\ EQ/AKParametricEQ.swift

./bin/generate_au_swift.rb interfaces/Dynamics/AUDynamicsProcessor.swift > ../AudioKit/Common/Nodes/Effects/Dynamics/Dynamics\ Processor/AKDynamicsProcessor.swift
./bin/generate_au_swift.rb interfaces/Dynamics/AUPeakLimiter.swift   > ../AudioKit/Common/Nodes/Effects/Dynamics/Peak\ Limiter/AKPeakLimiter.swift