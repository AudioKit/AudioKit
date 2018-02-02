//
//  AKPluckedString.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKPluckedStringDSP.hpp"

// "Constructor" function for interop with Swift

extern "C" void* createPluckedStringDSP(int nChannels, double sampleRate) {
    AKPluckedStringDSP* dsp = new AKPluckedStringDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}
