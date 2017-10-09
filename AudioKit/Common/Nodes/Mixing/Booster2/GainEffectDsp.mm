//
//  GainEffectDsp.cpp
//  AudioKit
//
//  Created by Andrew Voelkel on 9/23/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

#import "GainEffectDsp.hpp"

// "Constructor" function for interop with Swift
// In this case a destructor is not needed, since the DSP object doesn't do any of
// its own heap based allocation.

extern "C" void* createGainEffectDsp(int nChannels, double sampleRate) {
    AK4GainEffectDsp* dsp = new AK4GainEffectDsp();
    dsp->init(nChannels, sampleRate);
    return dsp;
}



