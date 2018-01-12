//
//  AKBandPassButterworthFilter.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKBandPassButterworthFilterDSP.hpp"

// "Constructor" function for interop with Swift

extern "C" void* createBandPassButterworthFilterDSP(int nChannels, double sampleRate) {
    AKBandPassButterworthFilterDSP* dsp = new AKBandPassButterworthFilterDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}
