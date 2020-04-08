//
//  AKPWMOscillator.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKPWMOscillatorDSP.hpp"

// "Constructor" function for interop with Swift

extern "C" AKDSPRef createPWMOscillatorDSP() {
    AKPWMOscillatorDSP *dsp = new AKPWMOscillatorDSP();
    return dsp;
}
