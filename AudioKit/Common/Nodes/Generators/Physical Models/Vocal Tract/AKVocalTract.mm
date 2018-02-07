//
//  AKVocalTract.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKVocalTractDSP.hpp"

// "Constructor" function for interop with Swift

extern "C" void* createVocalTractDSP(int nChannels, double sampleRate) {
    AKVocalTractDSP* dsp = new AKVocalTractDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}
