//
//  AKCombFilterReverb.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKCombFilterReverbDSP.hpp"

// "Constructor" function for interop with Swift

extern "C" void* createCombFilterReverbDSP(int nChannels, double sampleRate) {
    AKCombFilterReverbDSP* dsp = new AKCombFilterReverbDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}
