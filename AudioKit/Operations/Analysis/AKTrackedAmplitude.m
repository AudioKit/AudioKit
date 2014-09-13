//
//  AKTrackedAmplitude.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 11/12/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKTrackedAmplitude.h"

@implementation AKTrackedAmplitude
{
    AKAudio *asig;
}

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
{
    self = [super initWithString:[self operationName]];
    if (self) {
        asig = audioSource;
    }
    return self;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ rms %@",
            self, asig];
}

@end
