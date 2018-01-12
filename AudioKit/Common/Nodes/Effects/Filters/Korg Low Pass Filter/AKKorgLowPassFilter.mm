//
//  AKKorgLowPassFilter.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKKorgLowPassFilterDSP.hpp"

// "Constructor" function for interop with Swift

extern "C" void* createKorgLowPassFilterDSP(int nChannels, double sampleRate) {
    AKKorgLowPassFilterDSP* dsp = new AKKorgLowPassFilterDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}
