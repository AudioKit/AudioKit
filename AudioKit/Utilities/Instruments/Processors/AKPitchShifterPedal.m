//
//  AKPitchShifterPedal.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/27/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

#import "AKPitchShifterPedal.h"

@implementation AKPitchShifterPedal

- (instancetype)initWithInput:(AKAudio *)input
{
    self = [super init];
    if (self) {
        _frequencyShift = [self createPropertyWithValue:1   minimum:0.1 maximum:4];
        _feedback       = [self createPropertyWithValue:0.0 minimum:0   maximum:1.0];
        _mix            = [self createPropertyWithValue:0.5 minimum:0   maximum:1.0];
        
        AKPitchShifter *shifter = [AKPitchShifter pitchShifterWithInput:input];
        shifter.frequencyRatio = _frequencyShift;
        AKMix *mix = [[AKMix alloc] initWithInput1:input input2:shifter balance:_mix];
        
        _output = [AKAudio globalParameter];
        [self assignOutput:_output to:mix];
        
        //        [self resetParameter:input];
        AKAssignment *feedback = [[AKAssignment alloc] initWithOutput:input input:[shifter scaledBy:_feedback]];
        [self connect:feedback];
    }
    return self;
}

- (void)setPresetWitnessProtection
{
    _frequencyShift.value = 0.6;
    _feedback.value = 0.0;
    _mix.value = 1.0;
}

- (void)setPresetArcadeFire
{
    _frequencyShift.value = 1.2;
    _feedback.value = 0.99;
    _mix.value = 1.0;
}
- (void)setPresetHardBraker
{
    _frequencyShift.value = 0.9;
    _feedback.value = 0.99;
    _mix.value = 1.0;
}
- (void)setPresetPerfectFifthUp
{
    _frequencyShift.value = 3.0/2.0;
    _feedback.value = 0.0;
    _mix.value = 0.5;
}
- (void)setPresetPerfectFourthUp
{
    _frequencyShift.value = 4.0/3.0;
    _feedback.value = 0.0;
    _mix.value = 0.5;
}
- (void)setPresetPerfectFourthDown
{
    _frequencyShift.value = 3.0/4.0;
    _feedback.value = 0.0;
    _mix.value = 0.5;
}
- (void)setPresetPerfectFifthDown
{
    _frequencyShift.value = 2.0/3.0;
    _feedback.value = 0.0;
    _mix.value = 0.5;
}

@end