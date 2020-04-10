// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#import "AKPluckedStringDSP.hpp"

// "Constructor" function for interop with Swift

extern "C" AKDSPRef createPluckedStringDSP() {
    AKPluckedStringDSP *dsp = new AKPluckedStringDSP();
    return dsp;
}
