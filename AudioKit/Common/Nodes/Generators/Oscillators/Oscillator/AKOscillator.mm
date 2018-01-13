//
//  AKOscillator.mm
//  AudioKit
//
//  Created by Aurelius Prochazka on 1/12/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKOscillatorDSP.hpp"

// "Constructor" function for interop with Swift

extern "C" void* createOscillatorDSP(int nChannels, double sampleRate) {
    AKOscillatorDSP* dsp = new AKOscillatorDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

