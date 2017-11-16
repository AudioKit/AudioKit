//
//  AKChowningReverbAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#import "AKChowningReverbAudioUnit.h"
#import "AKChowningReverbDsp.hpp"

@implementation AKChowningReverbAudioUnit

-(void*)initDspWithSampleRate:(double) sampleRate channelCount:(AVAudioChannelCount) count {
    AKChowningReverbDsp* kernel = new AKChowningReverbDsp();
    kernel->init(sampleRate, count);
    return (void*)kernel;
}

@end


