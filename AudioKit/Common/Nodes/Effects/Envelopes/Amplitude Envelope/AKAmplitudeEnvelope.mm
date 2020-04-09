//
//  AKAmplitudeEnvelope.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKAmplitudeEnvelopeDSP.hpp"

// "Constructor" function for interop with Swift

extern "C" AKDSPRef createAmplitudeEnvelopeDSP() {
    AKAmplitudeEnvelopeDSP *dsp = new AKAmplitudeEnvelopeDSP();
    return dsp;
}
