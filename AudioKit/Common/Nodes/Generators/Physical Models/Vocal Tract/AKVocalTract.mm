//
//  AKVocalTract.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKVocalTractDSP.hpp"

// "Constructor" function for interop with Swift

extern "C" AKDSPRef createVocalTractDSP(int channelCount, double sampleRate) {
    AKVocalTractDSP *dsp = new AKVocalTractDSP();
    dsp->init(channelCount, sampleRate);
    return dsp;
}
