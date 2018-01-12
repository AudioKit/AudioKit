//
//  AKPeakingParametricEqualizerFilter.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKPeakingParametricEqualizerFilterDSP.hpp"

// "Constructor" function for interop with Swift

extern "C" void* createPeakingParametricEqualizerFilterDSP(int nChannels, double sampleRate) {
    AKPeakingParametricEqualizerFilterDSP* dsp = new AKPeakingParametricEqualizerFilterDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}
