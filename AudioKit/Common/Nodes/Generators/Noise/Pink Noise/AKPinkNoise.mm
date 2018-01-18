//
//  AKPinkNoise.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKPinkNoiseDSP.hpp"

// "Constructor" function for interop with Swift

extern "C" void* createPinkNoiseDSP(int nChannels, double sampleRate) {
    AKPinkNoiseDSP* dsp = new AKPinkNoiseDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}
