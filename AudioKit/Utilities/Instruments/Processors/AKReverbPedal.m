//
//  ReverbPedal.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 3/20/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKReverbPedal.h"

@implementation AKReverbPedal

- (instancetype)initWithInput:(AKAudio *)input
{
    self = [super init];
    if (self) {

        // Instrument Properties
        _feedback = [self createPropertyWithValue:0.5 minimum:0.0 maximum:1.0];
        _mix      = [self createPropertyWithValue:0.5 minimum:0.0 maximum:1.0];

        // Instrument Definition
        AKReverb *reverb = [AKReverb reverbWithInput:input];
        reverb.feedback = _feedback;
        
        AKMix *leftMix = [[AKMix alloc] initWithInput1:input input2:reverb.leftOutput balance:_mix];
        AKMix *rightMix = [[AKMix alloc] initWithInput1:input input2:reverb.rightOutput balance:_mix];
        
        _output = [AKStereoAudio globalParameter];
        [self assignOutput:_output.leftOutput to:leftMix];
        [self assignOutput:_output.rightOutput to:rightMix];

        // Reset Inputs
        [self resetParameter:input];
    }
    return self;
}
@end
