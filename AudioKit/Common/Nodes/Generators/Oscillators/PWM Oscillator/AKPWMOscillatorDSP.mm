// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#import "AKPWMOscillatorDSP.hpp"

// "Constructor" function for interop with Swift

extern "C" AKDSPRef createPWMOscillatorDSP() {
    AKPWMOscillatorDSP *dsp = new AKPWMOscillatorDSP();
    return dsp;
}
