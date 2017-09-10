//
//  AKChowningReverbAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#import "AK4ChowningReverbAudioUnit.h"
#import "AK4DspChowningReverb.hpp"

@implementation AK4ChowningReverbAudioUnit

-(AK4DspBase*)initDspWithSampleRate:(double) sampleRate channelCount:(AVAudioChannelCount) count {
    AK4DspChowningReverb* kernel = new AK4DspChowningReverb();
    kernel->init(sampleRate, count);
    return kernel;
}

@end


