//
//  AKRolandTB303Filter.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKRolandTB303FilterDSP.hpp"

// "Constructor" function for interop with Swift

extern "C" void* createRolandTB303FilterDSP(int nChannels, double sampleRate) {
    AKRolandTB303FilterDSP* dsp = new AKRolandTB303FilterDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}
