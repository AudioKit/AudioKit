//
//  AKChowningReverbAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 AudioKit. All rights reserved.
//

#import "AKChowningReverbAudioUnit.h"
#import "AKChowningReverbDSP.hpp"

@implementation AKChowningReverbAudioUnit

-(void*)initDSPWithSampleRate:(double) sampleRate channelCount:(AVAudioChannelCount) count {
    AKChowningReverbDSP* kernel = new AKChowningReverbDSP();
    kernel->init(sampleRate, count);
    return (void*)kernel;
}

@end


