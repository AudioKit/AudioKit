//
//  Amplifier.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 3/20/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAmplifier.h"

@implementation AKAmplifier

- (instancetype)initWithInput:(AKAudio *)audioSource
{
    self = [super init];
    if (self) {

        // Instrument Properties
        _amplitude = [self createPropertyWithValue:1.0 minimum:0.0 maximum:2.0];

        // Audio Output
        [self setAudioOutput:[audioSource scaledBy:_amplitude]];

        // Reset Inputs
        [self resetParameter:audioSource];
    }
    return self;
}
@end
