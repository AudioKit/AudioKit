//
//  AKFlatFrequencyResponseReverb.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKFlatFrequencyResponseReverbDSP.hpp"

// "Constructor" function for interop with Swift

extern "C" void* createFlatFrequencyResponseReverbDSP(int nChannels, double sampleRate) {
    AKFlatFrequencyResponseReverbDSP* dsp = new AKFlatFrequencyResponseReverbDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}
