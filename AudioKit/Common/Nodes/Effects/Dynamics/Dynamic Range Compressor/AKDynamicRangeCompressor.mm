//
//  AKDynamicRangeCompressor.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKDynamicRangeCompressorDSP.hpp"

// "Constructor" function for interop with Swift

extern "C" void* createDynamicRangeCompressorDSP(int nChannels, double sampleRate) {
    AKDynamicRangeCompressorDSP* dsp = new AKDynamicRangeCompressorDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}
