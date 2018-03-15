//
//  AKFlute.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKFluteDSP.hpp"

// "Constructor" function for interop with Swift

extern "C" void* createFluteDSP(int nChannels, double sampleRate) {
    AKFluteDSP* dsp = new AKFluteDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}
