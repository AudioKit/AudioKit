//
//  AKEqualizerFilter.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKEqualizerFilterDSP.hpp"

// "Constructor" function for interop with Swift

extern "C" void* createEqualizerFilterDSP(int nChannels, double sampleRate) {
    AKEqualizerFilterDSP* dsp = new AKEqualizerFilterDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}
