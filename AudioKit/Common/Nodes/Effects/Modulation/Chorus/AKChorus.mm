//
//  AKChorus.mm
//  AudioKit
//
//  Created by Shane Dunne on 2018-02-11.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKModulatedDelayDSP.hpp"

// "Constructor" function for interop with Swift
// !!!!In this case a destructor is not needed, since the DSP object doesn't do any of
// !!!!its own heap based allocation.

extern "C" void* createChorusDSP(int nChannels, double sampleRate) {
    return new AKModulatedDelayDSP(kChorus);
}
