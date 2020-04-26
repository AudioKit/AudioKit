// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#import "AKCombFilterReverbDSP.hpp"

// "Constructor" function for interop with Swift

extern "C" AKDSPRef createCombFilterReverbDSP() {
    AKCombFilterReverbDSP *dsp = new AKCombFilterReverbDSP();
    return dsp;
}
