// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#import "AKAmplitudeEnvelopeDSP.hpp"

// "Constructor" function for interop with Swift

extern "C" AKDSPRef createAmplitudeEnvelopeDSP() {
    AKAmplitudeEnvelopeDSP *dsp = new AKAmplitudeEnvelopeDSP();
    return dsp;
}
