// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#import "AKTremoloDSP.hpp"

// "Constructor" function for interop with Swift

extern "C" AKDSPRef createTremoloDSP() {
    AKTremoloDSP *dsp = new AKTremoloDSP();
    return dsp;
}
