//
//  AKAutoWah.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKAutoWahDSP.hpp"

// "Constructor" function for interop with Swift

extern "C" void* createAutoWahDSP(int nChannels, double sampleRate) {
    AKAutoWahDSP* dsp = new AKAutoWahDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}
