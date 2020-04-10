// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#import "AKAutoPannerDSP.hpp"

// "Constructor" function for interop with Swift

extern "C" AKDSPRef createAutoPannerDSP() {
    AKAutoPannerDSP *dsp = new AKAutoPannerDSP();
    return dsp;
}
