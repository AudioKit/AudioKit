//
//  AKStringResonator.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKStringResonatorDSP.hpp"

// "Constructor" function for interop with Swift

extern "C" void* createStringResonatorDSP(int nChannels, double sampleRate) {
    AKStringResonatorDSP* dsp = new AKStringResonatorDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}
