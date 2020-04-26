// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#import "AKStereoFieldLimiterDSP.hpp"

// "Constructor" function for interop with Swift
// In this case a destructor is not needed, since the DSP object doesn't do any of
// its own heap based allocation.

extern "C" AKDSPRef createStereoFieldLimiterDSP() {
    return new AKStereoFieldLimiterDSP();
}



