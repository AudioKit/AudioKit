//
//  AKDCBlock.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKDCBlockDSP.hpp"

// "Constructor" function for interop with Swift

extern "C" void* createDCBlockDSP(int nChannels, double sampleRate) {
    AKDCBlockDSP* dsp = new AKDCBlockDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}
