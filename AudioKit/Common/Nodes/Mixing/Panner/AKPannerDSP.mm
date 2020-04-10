// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#import "AKPannerDSP.hpp"

// "Constructor" function for interop with Swift

extern "C" AKDSPRef createPannerDSP() {
    AKPannerDSP *dsp = new AKPannerDSP();
    return dsp;
}
