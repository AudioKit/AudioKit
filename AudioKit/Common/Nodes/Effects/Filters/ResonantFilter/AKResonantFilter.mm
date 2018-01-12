//
//  AKResonantFilter.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKResonantFilterDSP.hpp"

// "Constructor" function for interop with Swift

extern "C" void* createResonantFilterDSP(int nChannels, double sampleRate) {
    AKResonantFilterDSP* dsp = new AKResonantFilterDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}
