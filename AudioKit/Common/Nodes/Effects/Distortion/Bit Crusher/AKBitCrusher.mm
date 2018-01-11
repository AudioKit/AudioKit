//
//  AKBitCrusher.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKBitCrusherDSP.hpp"

// "Constructor" function for interop with Swift

extern "C" void* createBitCrusherDSP(int nChannels, double sampleRate) {
    AKBitCrusherDSP* dsp = new AKBitCrusherDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}
