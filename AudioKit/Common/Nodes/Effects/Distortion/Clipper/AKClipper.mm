//
//  AKClipper.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKClipperDSP.hpp"

// "Constructor" function for interop with Swift

extern "C" void* createClipperDSP(int nChannels, double sampleRate) {
    AKClipperDSP* dsp = new AKClipperDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}
