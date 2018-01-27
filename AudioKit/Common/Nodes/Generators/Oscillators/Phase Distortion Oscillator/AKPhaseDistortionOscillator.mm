//
//  AKPhaseDistortionOscillator.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKPhaseDistortionOscillatorDSP.hpp"

// "Constructor" function for interop with Swift

extern "C" void* createPhaseDistortionOscillatorDSP(int nChannels, double sampleRate) {
    AKPhaseDistortionOscillatorDSP* dsp = new AKPhaseDistortionOscillatorDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}
