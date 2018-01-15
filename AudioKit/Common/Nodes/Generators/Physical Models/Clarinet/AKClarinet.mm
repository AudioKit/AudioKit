//
//  AKClarinet.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKClarinetDSP.hpp"

// "Constructor" function for interop with Swift

extern "C" void* createClarinetDSP(int nChannels, double sampleRate) {
    AKClarinetDSP* dsp = new AKClarinetDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}
