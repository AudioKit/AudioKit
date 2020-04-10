// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#import "AKPhaseDistortionOscillatorDSP.hpp"

// "Constructor" function for interop with Swift

extern "C" AKDSPRef createPhaseDistortionOscillatorDSP() {
    AKPhaseDistortionOscillatorDSP *dsp = new AKPhaseDistortionOscillatorDSP();
    return dsp;
}
