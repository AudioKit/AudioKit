//
//  AKPannerDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKPannerDSP.hpp"

// "Constructor" function for interop with Swift

extern "C" AKDSPRef createPannerDSP(int channelCount, double sampleRate) {
    AKPannerDSP *dsp = new AKPannerDSP();
    dsp->init(channelCount, sampleRate);
    return dsp;
}
