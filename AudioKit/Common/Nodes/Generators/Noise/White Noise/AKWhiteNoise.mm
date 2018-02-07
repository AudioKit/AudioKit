//
//  AKWhiteNoise.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKWhiteNoiseDSP.hpp"

// "Constructor" function for interop with Swift

extern "C" void* createWhiteNoiseDSP(int nChannels, double sampleRate) {
    AKWhiteNoiseDSP* dsp = new AKWhiteNoiseDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}
