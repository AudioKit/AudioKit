//
//  AKPitchShifter.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKPitchShifterDSP.hpp"

// "Constructor" function for interop with Swift

extern "C" void* createPitchShifterDSP(int nChannels, double sampleRate) {
    AKPitchShifterDSP* dsp = new AKPitchShifterDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}
