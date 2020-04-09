//
//  AKPhaseDistortionOscillator.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKPhaseDistortionOscillatorDSP.hpp"

// "Constructor" function for interop with Swift

extern "C" AKDSPRef createPhaseDistortionOscillatorDSP() {
    AKPhaseDistortionOscillatorDSP *dsp = new AKPhaseDistortionOscillatorDSP();
    return dsp;
}
