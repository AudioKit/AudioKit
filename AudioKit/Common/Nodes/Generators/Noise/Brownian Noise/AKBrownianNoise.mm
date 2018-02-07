//
//  AKBrownianNoise.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKBrownianNoiseDSP.hpp"

// "Constructor" function for interop with Swift

extern "C" void* createBrownianNoiseDSP(int nChannels, double sampleRate) {
    AKBrownianNoiseDSP* dsp = new AKBrownianNoiseDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}
