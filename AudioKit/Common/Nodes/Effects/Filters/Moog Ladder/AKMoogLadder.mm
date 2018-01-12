//
//  AKMoogLadder.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKMoogLadderDSP.hpp"

// "Constructor" function for interop with Swift

extern "C" void* createMoogLadderDSP(int nChannels, double sampleRate) {
    AKMoogLadderDSP* dsp = new AKMoogLadderDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}
