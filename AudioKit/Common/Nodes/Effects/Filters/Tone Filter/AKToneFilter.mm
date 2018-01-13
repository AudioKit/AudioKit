//
//  AKToneFilter.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKToneFilterDSP.hpp"

// "Constructor" function for interop with Swift

extern "C" void* createToneFilterDSP(int nChannels, double sampleRate) {
    AKToneFilterDSP* dsp = new AKToneFilterDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}
