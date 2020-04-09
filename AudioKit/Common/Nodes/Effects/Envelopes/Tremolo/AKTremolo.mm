//
//  AKTremolo.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKTremoloDSP.hpp"

// "Constructor" function for interop with Swift

extern "C" AKDSPRef createTremoloDSP() {
    AKTremoloDSP *dsp = new AKTremoloDSP();
    return dsp;
}
