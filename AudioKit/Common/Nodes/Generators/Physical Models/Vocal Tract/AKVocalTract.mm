// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#import "AKVocalTractDSP.hpp"

// "Constructor" function for interop with Swift

extern "C" AKDSPRef createVocalTractDSP() {
    AKVocalTractDSP *dsp = new AKVocalTractDSP();
    return dsp;
}
