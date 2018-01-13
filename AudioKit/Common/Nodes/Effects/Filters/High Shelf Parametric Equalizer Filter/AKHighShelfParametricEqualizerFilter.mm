//
//  AKHighShelfParametricEqualizerFilter.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKHighShelfParametricEqualizerFilterDSP.hpp"

// "Constructor" function for interop with Swift

extern "C" void* createHighShelfParametricEqualizerFilterDSP(int nChannels, double sampleRate) {
    AKHighShelfParametricEqualizerFilterDSP* dsp = new AKHighShelfParametricEqualizerFilterDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}
