//
//  FMSynthesizer.m
//  AudioKitDemo
//
//  Created by Aurelius Prochazka on 2/15/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "FMSynthesizer.h"

@implementation FMSynthesizer

- (instancetype)init
{
    self = [super init];
    if (self) {
        AKADSREnvelope *envelope = [[AKADSREnvelope alloc] initWithAttackDuration:akp(0.1)
                                                                    decayDuration:akp(0.1)
                                                                     sustainLevel:akp(0.5)
                                                                  releaseDuration:akp(0.3)
                                                                            delay:akp(0)];
        
        FMSynthesizerNote *note = [[FMSynthesizerNote alloc] init];
        AKFMOscillator *oscillator = [AKFMOscillator oscillator];
        oscillator.baseFrequency        = note.frequency;
        oscillator.carrierMultiplier    = [note.color scaledBy:akp(2)];
        oscillator.modulatingMultiplier = [note.color scaledBy:akp(3)];
        oscillator.modulationIndex      = [note.color scaledBy:akp(10)];
        oscillator.amplitude            = [envelope scaledBy:akp(0.25)];
        [self setAudioOutput:oscillator];
}
    return self;
}
@end

// -----------------------------------------------------------------------------
#  pragma mark - FMSynthesizer Note
// -----------------------------------------------------------------------------


@implementation FMSynthesizerNote

- (instancetype)init
{
    self = [super init];
    if (self) {
        _frequency = [self createPropertyWithValue:440 minimum:100 maximum:20000];
        _color     = [self createPropertyWithValue:0.0 minimum:0   maximum:1];
        self.duration.value = 1.0;
    }
    return self;
}

- (instancetype)initWithFrequency:(float)frequency color:(float)color
{
    self = [self init];
    if (self) {
        _frequency.value = frequency;
        _color.value = color;
    }
    return self;
}

@end
