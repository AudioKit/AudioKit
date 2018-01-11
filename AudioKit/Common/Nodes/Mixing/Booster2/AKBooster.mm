//
//  AKBooster.mm
//  AudioKit
//
//  Created by Andrew Voelkel on 9/23/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

#import "AKBoosterDSP.hpp"

// "Constructor" function for interop with Swift
// In this case a destructor is not needed, since the DSP object doesn't do any of
// its own heap based allocation.

extern "C" void* createBoosterDSP(int nChannels, double sampleRate) {
    AKBoosterDSP* dsp = new AKBoosterDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}



