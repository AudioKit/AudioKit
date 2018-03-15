//
//  AKZitaReverb.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKZitaReverbDSP.hpp"

// "Constructor" function for interop with Swift

extern "C" void* createZitaReverbDSP(int nChannels, double sampleRate) {
    AKZitaReverbDSP* dsp = new AKZitaReverbDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}
