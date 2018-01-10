//
//  AKCostelloReverbAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 AudioKit. All rights reserved.
//

#import "AKCostelloReverbDSP.hpp"

// "Constructor" function for interop with Swift

extern "C" void* createCostelloReverbDSP(int nChannels, double sampleRate) {
    AKCostelloReverbDSP* dsp = new AKCostelloReverbDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}
