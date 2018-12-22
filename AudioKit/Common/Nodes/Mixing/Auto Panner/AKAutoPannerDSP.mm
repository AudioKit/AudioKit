//
//  AKAutoPannerDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKAutoPannerDSP.hpp"

// "Constructor" function for interop with Swift

extern "C" AKDSPRef createAutoPannerDSP(int nChannels, double sampleRate) {
    AKAutoPannerDSP *dsp = new AKAutoPannerDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}
