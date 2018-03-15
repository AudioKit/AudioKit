//
//  AKFormantFilter.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKFormantFilterDSP.hpp"

// "Constructor" function for interop with Swift

extern "C" void* createFormantFilterDSP(int nChannels, double sampleRate) {
    AKFormantFilterDSP* dsp = new AKFormantFilterDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}
