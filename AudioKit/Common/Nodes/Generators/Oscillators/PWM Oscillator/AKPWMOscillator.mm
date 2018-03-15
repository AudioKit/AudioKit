//
//  AKPWMOscillator.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKPWMOscillatorDSP.hpp"

// "Constructor" function for interop with Swift

extern "C" void* createPWMOscillatorDSP(int nChannels, double sampleRate) {
    AKPWMOscillatorDSP* dsp = new AKPWMOscillatorDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}
