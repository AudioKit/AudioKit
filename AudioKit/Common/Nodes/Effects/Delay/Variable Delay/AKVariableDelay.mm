//
//  AKVariableDelay.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKVariableDelayDSP.hpp"

// "Constructor" function for interop with Swift

extern "C" void* createVariableDelayDSP(int nChannels, double sampleRate) {
    AKVariableDelayDSP* dsp = new AKVariableDelayDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}
