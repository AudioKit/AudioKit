//
//  AKPanner.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKPannerDSP.hpp"

// "Constructor" function for interop with Swift

extern "C" void* createPannerDSP(int nChannels, double sampleRate) {
    AKPannerDSP* dsp = new AKPannerDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}
