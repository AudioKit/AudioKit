//
//  AKPhaser.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKPhaserDSP.hpp"

// "Constructor" function for interop with Swift

extern "C" void* createPhaserDSP(int nChannels, double sampleRate) {
    AKPhaserDSP* dsp = new AKPhaserDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}
