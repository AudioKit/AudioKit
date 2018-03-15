//
//  AKBandRejectButterworthFilter.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKBandRejectButterworthFilterDSP.hpp"

// "Constructor" function for interop with Swift

extern "C" void* createBandRejectButterworthFilterDSP(int nChannels, double sampleRate) {
    AKBandRejectButterworthFilterDSP* dsp = new AKBandRejectButterworthFilterDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}
