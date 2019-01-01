//
//  AKPhaseDistortionOscillator.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKPhaseDistortionOscillatorDSP.hpp"

// "Constructor" function for interop with Swift

extern "C" AKDSPRef createPhaseDistortionOscillatorDSP(int channelCount, double sampleRate) {
    AKPhaseDistortionOscillatorDSP *dsp = new AKPhaseDistortionOscillatorDSP();
    dsp->init(channelCount, sampleRate);
    return dsp;
}
