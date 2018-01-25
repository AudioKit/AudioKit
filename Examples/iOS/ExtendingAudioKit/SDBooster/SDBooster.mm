//
//  SDBooster.mm
//  AudioKit
//
//  Created by Shane Dunne on 1/23/2018
//  Copyright © 2018 Shane Dunne. All rights reserved.
//

#import "SDBoosterDSP.hpp"

// "Constructor" function for interop with Swift
// In this case a destructor is not needed, since the DSP object doesn't do any of
// its own heap based allocation.

extern "C" void* createSDBoosterDSP(int nChannels, double sampleRate) {
    SDBoosterDSP* dsp = new SDBoosterDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}
