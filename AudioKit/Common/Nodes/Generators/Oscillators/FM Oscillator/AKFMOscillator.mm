//
//  AKFMOscillator.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKFMOscillatorDSP.hpp"

// "Constructor" function for interop with Swift

extern "C" void* createFMOscillatorDSP(int nChannels, double sampleRate) {
    AKFMOscillatorDSP* dsp = new AKFMOscillatorDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}
