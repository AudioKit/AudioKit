//
//  AKTanhDistortion.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKTanhDistortionDSP.hpp"

// "Constructor" function for interop with Swift

extern "C" void* createTanhDistortionDSP(int nChannels, double sampleRate) {
    AKTanhDistortionDSP* dsp = new AKTanhDistortionDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}
