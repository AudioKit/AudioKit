//
//  AKChowningReverbAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#import "AK4ChowningReverbAudioUnit.h"
#import "AK4ChowningReverbDsp.hpp"

@implementation AK4ChowningReverbAudioUnit

-(void*)initDspWithSampleRate:(double) sampleRate channelCount:(AVAudioChannelCount) count {
    AK4ChowningReverbDsp* kernel = new AK4ChowningReverbDsp();
    kernel->init(sampleRate, count);
    return (void*)kernel;
}

@end


