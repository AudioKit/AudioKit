//
//  ReverbProcessor.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 3/20/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "ReverbProcessor.h"

@implementation ReverbProcessor

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
{
    self = [super init];
    if (self) {

        // Instrument Properties
        _feedback = [self createPropertyWithValue:0.0 minimum:0.0 maximum:1.0];

        // Instrument Definition
        AKReverb *reverb = [[AKReverb alloc] initWithAudioSource:audioSource
                                                   feedbackLevel:_feedback
                                                 cutoffFrequency:akp(4000)];

        // Audio Output
        [self setStereoAudioOutput:reverb];

        // Reset Inputs
        [self resetParameter:audioSource];
    }
    return self;
}
@end
