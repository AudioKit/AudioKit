//
//  AKModalResonanceFilter.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKModalResonanceFilterDSP.hpp"

// "Constructor" function for interop with Swift

extern "C" void* createModalResonanceFilterDSP(int nChannels, double sampleRate) {
    AKModalResonanceFilterDSP* dsp = new AKModalResonanceFilterDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}
