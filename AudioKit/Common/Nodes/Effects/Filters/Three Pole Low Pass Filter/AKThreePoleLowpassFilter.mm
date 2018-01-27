//
//  AKThreePoleLowpassFilter.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKThreePoleLowpassFilterDSP.hpp"

// "Constructor" function for interop with Swift

extern "C" void* createThreePoleLowpassFilterDSP(int nChannels, double sampleRate) {
    AKThreePoleLowpassFilterDSP* dsp = new AKThreePoleLowpassFilterDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}
