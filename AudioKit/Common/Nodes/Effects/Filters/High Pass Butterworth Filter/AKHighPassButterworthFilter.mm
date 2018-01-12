//
//  AKHighPassButterworthFilter.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKHighPassButterworthFilterDSP.hpp"

// "Constructor" function for interop with Swift

extern "C" void* createHighPassButterworthFilterDSP(int nChannels, double sampleRate) {
    AKHighPassButterworthFilterDSP* dsp = new AKHighPassButterworthFilterDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}
