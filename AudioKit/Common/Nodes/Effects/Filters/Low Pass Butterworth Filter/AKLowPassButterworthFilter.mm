//
//  AKLowPassButterworthFilter.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKLowPassButterworthFilterDSP.hpp"

// "Constructor" function for interop with Swift

extern "C" void* createLowPassButterworthFilterDSP(int nChannels, double sampleRate) {
    AKLowPassButterworthFilterDSP* dsp = new AKLowPassButterworthFilterDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}
