//
//  AKChowningReverbAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 AudioKit. All rights reserved.
//

#import "AKChowningReverbDSP.hpp"

// "Constructor" function for interop with Swift

extern "C" void* createChowningReverbDSP(int nChannels, double sampleRate) {
    AKChowningReverbDSP* dsp = new AKChowningReverbDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}
