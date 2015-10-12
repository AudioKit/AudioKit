//
//  ReverbPedal.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 3/20/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKReverbPedal.h"

@implementation AKReverbPedal {
    AKAudio *_input;
}

- (instancetype)initWithInput:(AKAudio *)input
{
    self = [super init];
    if (self) {
        _input = input;
        // Instrument Properties
        _cutoffFrequency = [self createPropertyWithValue:4000 minimum:0 maximum:20000];
        _feedback = [self createPropertyWithValue:0.5 minimum:0.0 maximum:1.0];
        _mix      = [self createPropertyWithValue:0.5 minimum:0.0 maximum:1.0];
        
        // Instrument Definition
        AKReverb *reverb = [AKReverb reverbWithInput:input];
        reverb.feedback = _feedback;
        reverb.cutoffFrequency = _cutoffFrequency;
        
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

- (instancetype)initWithStereoInput:(AKStereoAudio *)input
{
    self = [super init];
    if (self) {
        // Instrument Based Control
        _feedback = [self createPropertyWithValue:0.5 minimum:0.0 maximum:1.0];
        _mix      = [self createPropertyWithValue:0.5 minimum:0.0 maximum:1.0];
        
        AKReverb *reverb;
        reverb = [[AKReverb alloc] initWithStereoInput:input];
        reverb.feedback = _feedback;
        
        AKMix *leftMix;
        leftMix = [[AKMix alloc] initWithInput1:input.leftOutput
                                         input2:reverb.leftOutput
                                        balance:_mix];
        
        AKMix *rightMix;
        rightMix = [[AKMix alloc] initWithInput1:input.rightOutput
                                          input2:reverb.rightOutput
                                         balance:_mix];

        _output = [AKStereoAudio globalParameter];
        [self assignOutput:_output.leftOutput to:leftMix];
        [self assignOutput:_output.rightOutput to:rightMix];

        
        // Reset Inputs
        [self resetParameter:input];
    }
    return self;
}

- (void)setPresetLargeHall
{
    AKReverb *reverb = [AKReverb presetLargeHallReverbWithInput:_input];
    _feedback.value = reverb.feedback.value;
    _cutoffFrequency.value = reverb.cutoffFrequency.value;
}

- (void)setPresetSmallHall
{
    AKReverb *reverb = [AKReverb presetSmallHallReverbWithInput:_input];
    _feedback.value = reverb.feedback.value;
    _cutoffFrequency.value = reverb.cutoffFrequency.value;
}

- (void)setPresetMuffledCan
{
    AKReverb *reverb = [AKReverb presetMuffledCanReverbWithInput:_input];
    _feedback.value = reverb.feedback.value;
    _cutoffFrequency.value = reverb.cutoffFrequency.value;
}
@end
