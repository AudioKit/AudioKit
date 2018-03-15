//
//  AKLowShelfParametricEqualizerFilter.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKLowShelfParametricEqualizerFilterDSP.hpp"

// "Constructor" function for interop with Swift

extern "C" void* createLowShelfParametricEqualizerFilterDSP(int nChannels, double sampleRate) {
    AKLowShelfParametricEqualizerFilterDSP* dsp = new AKLowShelfParametricEqualizerFilterDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}
